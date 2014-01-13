namespace :chunk_helper do
  require_relative "../data_to_chunks.rb"

  
  task :size_and_format_count => :environment do
    chunks = DataToChunks.extract_all_chunks
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

  task :write_chunks_to_file_by_size => :environment do
    DataToChunks.all_chunks_by_size.each do |size, chunks|
      File.open("Size_#{size}.txt","w") do |f|
        chunks.each do |chunk|
          chunk.data.each do |line|
            f.write line
          end
        end
      end  
    end
  end

  task :write_chunks_to_file_by_format => :environment do
    chunks_by_format = DataToChunks.all_chunks_by_format

    size_occurences = {}
    chunks_by_format.each do |format, chunks|
      size_occurences[format.size] = 0
    end

    chunks_by_format.each do |format, chunks|
      File.open("Size_#{format.size}_Form_#{size_occurences[format.size]}.txt","w") do |f|
        chunks.each do |chunk|
          chunk.data.each do |line|
            f.write line
          end
        end
      end
      size_occurences[format.size] += 1  
    end
  end

end