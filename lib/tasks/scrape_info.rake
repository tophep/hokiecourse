namespace :scrape_info do
  require 'rake'
  require 'open-uri'
  require_relative '../chunks_to_courses.rb'
  require_relative '../data_to_chunks.rb'

  
  TIME_TABLE_URL = "https://banweb.banner.vt.edu/ssb/prod/HZSKVTSC.P_ProcRequest"
  COURSE_LISTING_DIRECTORY = DataToChunks::COURSE_LISTING_DIRECTORY

  def delete_course_listings
    dir = COURSE_LISTING_DIRECTORY 
    Dir.foreach(dir) {|f| fn = File.join(dir, f); File.delete(fn) if f != '.' && f != '..'}
  end

  def parse_html(page)
    info = Array.new
    page.parser.css("td").each do |item|
      content = item.content
      lines = content.split("\n")
      lines.each do |line|
        info.push(line.strip)
      end

      if lines.empty? && !content.empty?
        info.push("")
      end
      
      while content.end_with?("\n")
        info.push("")
        content = content[0..-2]
      end
    end
    info
  end

  # def parse_test(page)
  #   sizes = Hash.new(0)
  #   page.parser.css("table.dataentrytable tr").each do |line|
  #     contents = line.content
  #     if contents[/(\A|\D)\d{5}&nbsp/].to_s[/\d{5}/]
  #       contents = contents.split(/\s+/)
  #       size = contents.size
  #       sizes[size] += 1
  #     end
  #   end
  #   return sizes
  # end


  task :test => :environment do

    stuff = []

    agent = Mechanize.new
    page = agent.get(TIME_TABLE_URL)
    form = page.forms[0]
      

    Subject.all.reverse.each do |sub|
      form.subj_code = sub.abbrev
      form.TERMYEAR = "201409"
      page = agent.submit(form)
      
      stuff.concat parse_test(page)
      stuff.uniq!

    end

    puts stuff
  end


  task :all => :environment do
    reading = false
    available_terms = []

    open(TIME_TABLE_URL).each do |line|
      if line.downcase.include? 'select term'
        reading = true
        next
      elsif reading
        if term_code = line[/\d{6}/]
          available_terms << term_code
        else
          break
        end
      end
    end
    
    available_terms.each do |term_code|
      Rake::Task["scrape_info:by_term"].execute(term_code: term_code)
    end
  end

  task :by_term, [:term_code] => [:environment] do |t, args|
    term_code = args[:term_code]
    
    
    Rake::Task["scrape_info:scrape_subjects"].execute(term_code: term_code)
    Rake::Task["scrape_info:scrape_courses"].execute(term_code: term_code)
    Rake::Task["scrape_info:update_open_courses"].execute(term_code: term_code)
  end


  task :scrape_subjects, [:term_code] => [:environment] do |t, args|
    term_code = args[:term_code]
  	reading = false

    open(TIME_TABLE_URL).each do |line|
      if line.downcase.include?('case') && line.include?(term_code)
        reading = true
        next
      elsif reading && line.blank?
        reading = false
        break
      elsif reading
        if line.match(/"(.+)( -)/)  # This condition skips the "All Subjects" option by detecting a dash mark
        	abbrev = line.match(/"(.+)( -)/)[1]
        	name = line.match(/(- )(.+)(",")/)[2]
        	if abbrev && !Subject.find_by_abbrev(abbrev)
            if Subject.create(name:name, abbrev:abbrev)
              puts "Created new subject: #{abbrev} - #{name}"
            else
              puts "Failed to create new subject: #{abbrev} - #{name}"
              puts "\n#{'#'*50}\nABORTING TASKS\nPLEASE RESOLVE ERRORS\n#{'#'*50}\n"
              abort
            end
          end
        end
      end
    end
  end

  task :write_course_listings, [:term_code, :open_only] => [:environment] do |t, args|
    delete_course_listings

    term_code = args[:term_code]
  	agent = Mechanize.new
  	page = agent.get(TIME_TABLE_URL)
  	form = page.forms[0]
  
    Subject.all.each do |sub|
      form.subj_code = sub.abbrev
      form.TERMYEAR = term_code
      form.open_only = "on" if args[:open_only]
      new_page = agent.submit form
      file_path = COURSE_LISTING_DIRECTORY + sub.abbrev + ".html"
      new_page.save_as(file_path)
      puts "Saved Course Listings For #{sub.abbrev}"

      doc = Nokogiri::HTML(File.open(file_path))

      File.open(file_path, 'w') do |f|
        doc.css("td").each do |item|
          f.write(item.content)
          f.write("\n")
        end
      end

      file = open(file_path)
      info = file.to_a
      file.close
      unless DataToChunks.first_crn_line(info)
        puts "#{sub.abbrev} Course List Deleted: No Courses Registered for Subject #{sub.name}"
        File.delete file_path
      end

    end
  end


  task :scrape_courses, [:term_code] => [:environment] do |t, args|

    term_code = args[:term_code]
    year = term_code[0,4]
    term = term_code[4,6]
    all_chunks = Array.new

    agent = Mechanize.new
    page = agent.get(TIME_TABLE_URL)
    form = page.forms[0]
  
    Subject.all.each do |sub|
      form.subj_code = sub.abbrev
      form.TERMYEAR = term_code
      page = agent.submit(form)
      

      info = parse_html(page)

      if chunks = DataToChunks.extract_chunks(info)
        all_chunks += chunks
      end
    end

    all_chunks.each do |chunk|
      unless ChunksToCourses.create_course_from_chunk(chunk, year, term)
        puts "Failed To Create Course #{chunk.data[0]}"
        puts "Course May Be Registered To A Satellite Campus"
      end
    end

  end

  task :update_open_courses, [:term_code] => [:environment] do |t, args|

    term_code = args[:term_code]
    year = term_code[0,4]
    term = term_code[4,6]
    all_chunks = Array.new

    agent = Mechanize.new
    page = agent.get(TIME_TABLE_URL)
    form = page.forms[0]
  
    Subject.all.each do |sub|
      form.subj_code = sub.abbrev
      form.TERMYEAR = term_code
      form.open_only = "on"
      page = agent.submit(form)
      

      info = parse_html(page)

      if chunks = DataToChunks.extract_chunks(info)
        all_chunks += chunks
      end
    end

    ChunksToCourses.update_open_courses(all_chunks, year, term)

  end

  task :chunk_info, [:term_code] => [:environment] do |t, args|
    term_code = args[:term_code]

    agent = Mechanize.new
    page = agent.get(TIME_TABLE_URL)
    form = page.forms[0]

    chunks = Array.new
  
    Subject.all.each do |sub|
      form.subj_code = sub.abbrev
      form.TERMYEAR = term_code
      page = agent.submit(form)
      

      info = parse_html(page)

      if c = DataToChunks.extract_chunks(info)
        chunks += c
      end
    end

    total_chunks = chunks.size
    sizes = {}
    formats = Array.new
    chunks.each do |chunk|
      if sizes[chunk.size]
        sizes[chunk.size][0] += 1
      else
        sizes[chunk.size] = [1, 0]
      end
      unless formats.include? chunk.format
        formats << chunk.format
        sizes[chunk.size][1] += 1
      end
    end
    puts "\n#{total_chunks} CHUNKS\n#{sizes.size} SIZES\n#{formats.size} FORMATS"
    puts "\n\nCHUNK SIZES:"
    sizes.sort.each {|size, count| puts "\n#{size} Lines : \n  #{count[0]} Occurence(s)\n  #{count[1]} Format(s)"}
  end

end