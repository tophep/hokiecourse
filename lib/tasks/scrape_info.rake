namespace :scrape_info do
  require 'rake'
  require 'open-uri'
  require_relative '../chunks_to_courses.rb'
  require_relative '../data_to_chunks.rb'

  TERM_CODE_MAP = {"09" => "Fall", "12" => "Winter", "01" => "Spring", "06" => "Summer I", "07" => "Summer II"}
  TIME_TABLE_URL = "https://banweb.banner.vt.edu/ssb/prod/HZSKVTSC.P_ProcRequest"
  COURSE_LISTING_DIRECTORY = DataToChunks::COURSE_LISTING_DIRECTORY

  def delete_course_listings
    dir_path = COURSE_LISTING_DIRECTORY
    Dir.foreach(dir_path) {|f| fn = File.join(dir_path, f); File.delete(fn) if f != '.' && f != '..'}
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
    year = term_code[0,4]
    term = TERM_CODE_MAP[term_code[4,6]]
    
    
    Rake::Task["scrape_info:scrape_subjects"].execute(term_code: term_code)
    Rake::Task["scrape_info:scrape_course_listings"].execute(term_code: term_code)
    Rake::Task["scrape_info:strip_course_listings"].execute
    Rake::Task["scrape_info:remove_empty_course_listings"].execute
    ChunksToCourses.create_all_courses(year, term)
    Rake::Task["scrape_info:update_open_courses"].execute(term_code: term_code)
  end

  task :update_open_courses, [:term_code] => [:environment] do |t, args|
    term_code = args[:term_code]
    year = term_code[0,4]
    term = TERM_CODE_MAP[term_code[4,6]]

    Rake::Task["scrape_info:scrape_course_listings"].execute(term_code: term_code, open_only: true)
    Rake::Task["scrape_info:strip_course_listings"].execute
    Rake::Task["scrape_info:remove_empty_course_listings"].execute
    ChunksToCourses.update_open_courses(year, term)
  end

  task :scrape_subjects, [:term_code] => [:environment] do |t, args|
    term_code = args[:term_code]
  	reading = false

    open(TIME_TABLE_URL).each do |line|
      if line.include?('case') && line.include?(term_code)
        reading = true
        next
      elsif reading && line.blank?
        reading = false
        next
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

  task :scrape_course_listings, [:term_code, :open_only] => [:environment] do |t, args|
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
    end
  end


  task :strip_course_listings => :environment do
    Subject.all.each do |sub|
      file_path = COURSE_LISTING_DIRECTORY + sub.abbrev + ".html"
      doc = Nokogiri::HTML(File.open(file_path))

      File.open(file_path, 'w') do |f|
        doc.css("td").each do |item|
          f.write(item.content)
          f.write("\n")
        end
      end
    end
  end

  task :remove_empty_course_listings => :environment do
    Subject.all.each do |sub|
      file_path = COURSE_LISTING_DIRECTORY + sub.abbrev + ".html"
      if File.exists?(file_path)
        file = open(file_path)
        info = file.to_a
        file.close
        unless DataToChunks.first_crn_line(info)
          puts "#{sub.abbrev} Course List Deleted: No Courses Registered for Subject"
          File.delete file_path
        end
      end
    end
  end


  task :test => :environment do

    b1 = File.open("box1").to_a
    b2 = File.open("box2").to_a

    puts b1.size
    puts b2.size

    b1.each_with_index do |line, i|
      if line != b2[i]
        puts i
      end
    end

  end
end