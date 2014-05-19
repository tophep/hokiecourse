class Course < ActiveRecord::Base

	attr_accessible :crn, :title, :online, :cred_hours, :instructor, :begin, :end, :location, :days,
					:subject_id, :subject_code, :year, :term, :term_code, :open

	belongs_to :subject
	has_many :additional_times, :dependent => :destroy

	def pretty_begin
		Time.parse(self.begin).strftime("%l:%M %p") if self.begin
	end

	def pretty_end
		Time.parse(self.end).strftime("%l:%M %p") if self.end
	end

	def times_overlap?(begin1, end1, begin2, end2)
		return false unless begin1 && end1 && begin2 && end2 
		(begin1 <= end2) && (begin2 <= end1)
	end

	def days_overlap?(days1, days2)
		if days1 && days2
			days1 = days1.split(" ")
			days1.each {|d| return true if days2.include? d}
		end
		return false
	end

	def conflict_with?(other_course)
		this_course = self.additional_times.to_a << self
		other_course = other_course.additional_times.to_a << other_course
		this_course.each do |c1|
			other_course.each do |c2|
				if days_overlap?(c1.days, c2.days) && times_overlap?(c1.begin, c1.end, c2.begin, c2.end)
					return true
				end
			end
		end
		return false
	end

	def banner_url
		sub = self.subject_code.split("-")[0]
		num = self.subject_code.split("-")[1]
		"https://banweb.banner.vt.edu/ssb/prod/HZSKVTSC.P_ProcComments?CRN=#{self.crn}&TERM=#{self.term_code}&YEAR=#{self.year}&SUBJ=#{sub}&CRSE=#{num}&history=N"
	end

end
