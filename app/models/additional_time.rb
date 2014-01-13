class AdditionalTime < ActiveRecord::Base

	attr_accessible :begin, :end, :location, :days, :course_id, :order
	belongs_to :course
end