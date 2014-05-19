class Chunk
	# Chunks are precursors to Course Objects

    # They represent and contain an array of strings (@data) extracted from scraped html
    # These strings describe the meta-data (day, time, room, professor, etc) for a single VT course


	# The data is used to create a format
	# The format of a chunk is an array of booleans, where each element corresponds to the element in the data 
	# at the same index
	# A format element is false if the corresponding data element is a blank string, true otherwise
	# Formats identify how the chunk should be parsed into a Course object

    def initialize(data, is_end_chunk = false)
    	@data = data

        if is_end_chunk
            normalize
        end
    end

    def size
    	@data.size
    end

    def data
    	@data
    end

  	def format
  		format = Array.new
        data.each do |line|
          format << !line.blank?
        end
        format
  	end

    private

    # The last chunk in each file is missing a blank line at the end that other chunks all contain
    # This method "normalizes" these end-chunks so that their format is recognized during parsing 
    def normalize
        @data << ""
    end

end