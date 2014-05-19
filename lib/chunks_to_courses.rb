module ChunksToCourses
	require_relative 'data_to_chunks.rb'

	# This module is used to create the course objects in the database
	# Each chunk format has different pieces of course information on different lines, therefore
	# constants are used to map formats to a list of attribute locations by line number
	# The locations can then be used to easily extract the necessary field values from the chunk data,
	# to create a course object in the database

	TERM_CODE_MAP = {"09" => "Fall", "12" => "Winter", "01" => "Spring", "06" => "Summer I", "07" => "Summer II"}

	# The possible chunk formats
	SIZE_14_Form_0 = [true, false, false, true, false, true, true, false, false, true, false, true, true, false]
	SIZE_15_Form_0 = [true, false, false, true, false, true, false, true, false, false, true, false, true, true, false]
	SIZE_20_Form_0 = [true, false, false, true, false, true, true, false, false, true, false, true, true, true, true, true, false, true, false, false]
	SIZE_21_Form_0 = [true, false, false, true, false, true, false, true, false, false, true, false, true, true, true, true, true, false, true, false, false]
	SIZE_21_Form_1 = [true, false, false, true, false, true, true, false, false, true, false, true, true, true, false, true, true, false, true, false, false]
	SIZE_21_Form_2 = [true, false, false, true, false, true, true, false, false, true, false, true, true, true, true, true, true, false, true, false, false]
	SIZE_22_Form_0 = [true, false, false, true, false, true, false, true, false, false, true, false, true, true, true, true, true, true, false, true, false, false]
	SIZE_31_Form_0 = [true, false, false, true, false, true, false, true, false, false, true, false, true, true, true, true, true, false, true, false, false, false, false, false, true, true, true, true, true, false, false]
	SIZE_31_Form_1 = [true, false, false, true, false, true, false, true, false, false, true, false, true, true, true, true, true, true, false, true, false, false, false, false, false, true, true, true, true, false, false]
	SIZE_32_Form_0 = [true, false, false, true, false, true, false, true, false, false, true, false, true, true, true, true, true, true, false, true, false, false, false, false, false, true, true, true, true, true, false, false]
	SIZE_42_Form_0 = [true, false, false, true, false, true, false, true, false, false, true, false, true, true, true, true, true, true, false, true, false, false, false, false, false, true, true, true, true, true, false, false, false, false, false, true, true, true, true, true, false, false]

	# The locations (index/line number) of the various course attributes for each format
	ATTRIBUTES_14_Form_0 = {crn:0,subject_code:3,title:5,online:6,cred_hours:9,instructor:12}
	ATTRIBUTES_15_Form_0 = {crn:0,subject_code:3,title:5,cred_hours:10,instructor:13}
	ATTRIBUTES_20_Form_0 = {crn:0,subject_code:3,title:5,online:6,cred_hours:9,instructor:12}
	ATTRIBUTES_21_Form_0 = {crn:0,subject_code:3,title:5,cred_hours:10,instructor:13}
	ATTRIBUTES_21_Form_1 = {crn:0,subject_code:3,title:5,online:6,cred_hours:9,instructor:12}
	ATTRIBUTES_21_Form_2 = {crn:0,subject_code:3,title:5,online:6,cred_hours:9,instructor:12}
	ATTRIBUTES_22_Form_0 = {crn:0,subject_code:3,title:5,cred_hours:10,instructor:13,days:14, :begin => 15, :end => 16,location:17}
	ATTRIBUTES_31_Form_0 = {crn:0,subject_code:3,title:5,cred_hours:10,instructor:13,additional_time_1:{days:25,:begin=>26,:end=>27,location:28}}
	ATTRIBUTES_31_Form_1 = {crn:0,subject_code:3,title:5,cred_hours:10,instructor:13,days:14,:begin =>15,:end => 16,location: 17}
	ATTRIBUTES_32_Form_0 = {crn:0,subject_code:3,title:5,cred_hours:10,instructor:13,days:14,:begin => 15, :end => 16, location:17, additional_time_1:{days:26,:begin=>27,:end=>28,location:29}}
	ATTRIBUTES_42_Form_0 = {crn:0,subject_code:3,title:5,cred_hours:10,instructor:13,days:14,:begin => 15, :end => 16, location:17, additional_time_1:{days:26,:begin=>27,:end=>28,location:29}, additional_time_2:{days:36,:begin => 37, :end => 38, location:39}}

	# Maps formats to the corresponding attribute location hash
	FORMAT_TO_ATTRIBUTE_MAP = {
		SIZE_14_Form_0 => ATTRIBUTES_14_Form_0, 
		SIZE_15_Form_0 => ATTRIBUTES_15_Form_0, 
		SIZE_20_Form_0 => ATTRIBUTES_20_Form_0, 
		SIZE_21_Form_0 => ATTRIBUTES_21_Form_0, 
		SIZE_21_Form_1 => ATTRIBUTES_21_Form_1, 
		SIZE_21_Form_2 => ATTRIBUTES_21_Form_2,
		SIZE_22_Form_0 => ATTRIBUTES_22_Form_0, 
		SIZE_31_Form_0 => ATTRIBUTES_31_Form_0, 
		SIZE_31_Form_1 => ATTRIBUTES_31_Form_1, 
		SIZE_32_Form_0 => ATTRIBUTES_32_Form_0, 
		SIZE_42_Form_0 => ATTRIBUTES_42_Form_0
		}


	# Assumes the currently saved course listings are of open courses only
	def self.update_open_courses(chunks, year, term_code)
		Course.where(year: year, term_code: term_code).each do |course|
			course.update_attributes(open: false)
		end

		chunks.each do |chunk|
			crn = DataToChunks.extract_crn(chunk.data.first)
			if course = Course.where(year: year, term_code: term_code, crn: crn).first
				course.update_attributes(open: true)
			end
		end
	end

	# Creates a course and any accompanying additional times, from a specified chunk
	def self.create_course_from_chunk(chunk, year, term_code)
		if attributes = extract_attributes_from_chunk(chunk)
			attributes[:year] = year
			attributes[:term_code] = term_code
			attributes[:term] = TERM_CODE_MAP[term_code]
			additional_times = attributes.delete(:additional_times)

			course = create_course(attributes)

			additional_times.each do |additional_attr|
				additional_attr[:course_id] = course.id
				create_additional_time(additional_attr)
			end
			return course
		end
	end

	# Creates or updates a course object with the attributes specified
	def self.create_course(attributes)
		if course = Course.find_by(crn: attributes[:crn], year: attributes[:year], term_code: attributes[:term_code])
			course.update_attributes(attributes)
			course
		else
			Course.create(attributes)
			Course.last
		end
	end

	# Creates or updates an additional time object with the attributes specified
	def self.create_additional_time(attributes)
		if additional_time = AdditionalTime.find_by(course_id: attributes[:course_id], order: attributes[:order])
			additional_time.update_attributes(attributes)
			additional_time
		else
			AdditionalTime.create(attributes)
			AdditionalTime.last
		end
	end

	# Returns a hash of course attributes and their values, extracted from the specified chunk
	def self.extract_attributes_from_chunk(chunk)
		info = chunk.data
		if attribute_locations = FORMAT_TO_ATTRIBUTE_MAP[chunk.format]
			course_attributes = {additional_times: []}

			attribute_locations.each do |attribute, location|
				value = info[location].strip unless location.is_a?(Hash)

				case attribute

				when :crn
					crn = DataToChunks.extract_crn(value)
					course_attributes[:crn] = crn
				when :subject_code
					course_attributes[:subject_code] = value
					subject_and_number = value.split("-")
					abbrev = subject_and_number[0]
					course_attributes[:subject_id] = Subject.find_by_abbrev(abbrev).id
				when :title
					course_attributes[:title] = value
				when :online
					course_attributes[:online] = true if value.downcase.include?("online")
				when :cred_hours
					course_attributes[:cred_hours] = value if value[/\d+/] == value
				when :instructor
					course_attributes[:instructor] = value
				when :days
					course_attributes[:days] = value
				when :begin
					course_attributes[:begin] = parse_time(value)
				when :end
					course_attributes[:end] = parse_time(value)
				when :location
					course_attributes[attribute] = value

				when :additional_time_1
					additional_attr_1 = {order: 1}
					location.each do |att, loc|
						val = info[loc].strip
						case att
						when :days
							additional_attr_1[:days] = val
						when :begin
							additional_attr_1[:begin] = parse_time(val)
						when :end
							additional_attr_1[:end] = parse_time(val)
						when :location
							additional_attr_1[:location] = val
						end
					end
					course_attributes[:additional_times] << additional_attr_1

				when :additional_time_2
					additional_attr_2 = {order: 2}
					location.each do |att, loc|
						val = info[loc].strip
						case att
						when :days
							additional_attr_2[:days] = val
						when :begin
							additional_attr_2[:begin] = parse_time(val)
						when :end
							additional_attr_2[:end] = parse_time(val)
						when :location
							additional_attr_2[:location] = val
						end
					end
					course_attributes[:additional_times] << additional_attr_2
				end	
			end

			course_attributes
		end
	end

	# Converts AM/PM time strings to 24-hour time
	def self.parse_time(time)
		Time.parse(time).strftime("%H:%M")
	end

end