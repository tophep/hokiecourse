module ScheduleMaker

	def self.times_overlap?(begin1, end1, begin2, end2)
		(begin1 <= end2) and (begin2 <= end1)
	end

	def self.days_overlap?(days1, days2)
		if days1 && days2
			days1 = days1.split(" ")
			days1.each {|d| return true if days2.include? d}
		end
		return false
	end

	def self.courses_conflict?(course1, course2)
		course1 = course1.additional_times.to_a << course1
		course2 = course2.additional_times.to_a << course2
		course1.each do |c1|
			course2.each do |c2|
				if days_overlap?(c1.days, c2.days) && times_overlap?(c1.begin, c1.end, c2.begin, c2.end)
					return true
				end
			end
		end
		return false
	end

	def self.set_of_courses_conflict?(course_array)
		size = course_array.size
		for i in 0..size-2
			for j in i+1..size-1
				return true if courses_conflict?(course_array[i], course_array[j])
			end
		end
		return false
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

	# Given last_index parameter to increase efficiency, last_index only needs to be generated once
	# inside the generate_valid_combo method, instead of every time inside this method
	def self.increment_index_array(index_array, sizes_array, last_index)
		index_array[last_index] += 1
		for i in (last_index).downto(0)
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

	def self.extract_combo(course_lists, index_array, last_index)
		combo = Array.new
		for i in 0..last_index
			combo << course_lists[i][index_array[i]]
		end
		return combo
	end

	def self.generate_valid_combo(course_lists, index_array = nil)
		index_array ||= blank_index_array(course_lists)
		list_sizes = sizes_array(course_lists)
		last_index = course_lists.size - 1

		loop do
			combo = extract_combo(course_lists, index_array, last_index)
			index_array = increment_index_array(index_array, list_sizes, last_index)
			return [combo, index_array] unless set_of_courses_conflict?(combo)
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

	def self.all_course_sections(course_code_array)
		course_sections = Array.new
		course_code_array.each do |course_code|
			course_sections << Course.where(subject_code:course_code)
		end
		course_sections
	end


end