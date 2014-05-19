class ScheduleBuilder < ActiveRecord::Base

	def self.build_schedule(raw_course_codes)
		course_codes = parse_course_codes(raw_course_codes)
		course_lists = all_course_sections(course_codes)
		generate_valid_combo(course_lists)[0]
	end

	def self.parse_course_codes(course_code_array)
		parsed_codes = Array.new
		course_code_array.each do |code|
			if code && !code.empty?
				parsed = code[/[a-zA-Z]+/] + "-" + code[/\d+/]
				parsed_codes << parsed.upcase
			end
		end
		parsed_codes
	end

	def self.all_course_sections(course_code_array)
		course_sections = Array.new
		course_code_array.each do |course_code|
			course_sections << Course.where(subject_code:course_code)
		end
		course_sections
	end

	def self.valid_schedule?(course_array)
		size = course_array.size
		for i in 0..size-2
			for j in i+1..size-1
				return false if course_array[i].conflict_with? course_array[j]
			end
		end
		return true
	end

	def self.blank_index_array(course_lists)
		Array.new(course_lists.size,0)
	end

	def self.sizes_array(course_lists)
		sizes = Array.new
		course_lists.each_with_index do |list, i|
			sizes[i] = list.size
		end
		sizes
	end


	def self.increment_index_array(index_array, sizes_array)
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

	def self.extract_combo(course_lists, index_array)
		combo = Array.new
		for i in 0..(index_array.size - 1)
			combo << course_lists[i][index_array[i]]
		end
		return combo
	end

	def self.generate_valid_combo(course_lists, index_array = nil)
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

	def self.generate_all_valid_combos(course_lists)
		index_array = blank_index_array(course_lists)
		combos = []
		while combo_and_index = generate_valid_combo(course_lists, index_array)
			combos << combo_and_index[0]
			index_array = combo_and_index[1]
		end
		return combos
	end

	


end