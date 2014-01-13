class Course < ActiveRecord::Base

	attr_accessible :crn, :title, :online, :cred_hours, :instructor, :begin, :end, :location, :days,
					:subject_id, :subject_code, :year, :term, :open

	belongs_to :subject
	has_many :additional_times, :dependent => :destroy

end
