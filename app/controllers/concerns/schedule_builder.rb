module ScheduleBuilder

	def build_schedule(request)
		
	end

	def validate_codes(year, term_code, codes, code_type)
		valid_codes = []
		codes.each_with_index do |code, i|
			sections = Course.where(year:year, term_code:term_code, code_type => code).size
			valid_codes << code if sections > 0
		end
		valid_codes
	end


	def parse_subject_code(code)
		if code && !code.blank?
			subject = code[/[a-zA-Z]+/]
			number =  code[/\d+/]
			if subject && number then "#{subject}-#{number}".upcase else code end
		end
	end

	def parse_crn(crn)
		crn if crn && !crn.blank?
	end

		# Assumes all subject_codes and crn's have been validated
	def all_course_sections(subject_codes, year, term, time_range = nil)
		course_sections = []
		if params[:crns]
			params[:crns].each do |crn|
				course_sections << Course.where(year:year, term_code:term, crn:crn)
			end
		end
		subject_codes.each do |subject_code|
			sections = Course.where(year:year, term_code:term, subject_code:subject_code)
			sections = sections.where(:begin => nil) + sections.where(:begin => time_range) if time_range
			course_sections << sections if sections.size > 0
		end
		course_sections
	end

	def valid_schedule?(course_array)
		size = course_array.size
		for i in 0..size-2
			for j in i+1..size-1
				return false if course_array[i].conflict_with? course_array[j]
			end
		end
		return true
	end

	def blank_index_array(course_lists)
		Array.new(course_lists.size,0)
	end

	def sizes_array(course_lists)
		sizes = []
		course_lists.each_with_index do |list, i|
			sizes[i] = list.size
		end
		sizes
	end


	def increment_index_array(index_array, sizes_array)
		i_max = index_array.size - 1
		index_array[i_max] += 1

		for i in (i_max).downto(0)
			if index_array[i] == sizes_array[i]
				return nil if i == 0
				index_array[i] = 0
				index_array[i-1] += 1
			else
				break
			end
		end
		return index_array
	end

	def extract_combo(course_lists, index_array)
		combo = []
		for i in 0..(index_array.size - 1)
			combo << course_lists[i][index_array[i]]
		end
		return combo
	end

	def generate_valid_combo(course_lists, index_array = nil)
		index_array ||= blank_index_array(course_lists)
		list_sizes = sizes_array(course_lists)

		loop do
			combo = extract_combo(course_lists, index_array)
			index_array = increment_index_array(index_array, list_sizes)
			return [combo, index_array] if valid_schedule?(combo)
			break unless index_array
		end
		return nil
	end

	def generate_all_valid_combos(course_lists)
		index_array = blank_index_array(course_lists)
		combos = []
		while combo_and_index = generate_valid_combo(course_lists, index_array)
			combos << combo_and_index[0]
			index_array = combo_and_index[1]
		end
		return combos
	end

	


end