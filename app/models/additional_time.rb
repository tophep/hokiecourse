class AdditionalTime < ActiveRecord::Base

	attr_accessible :begin, :end, :location, :days, :course_id, :order
	belongs_to :course

	def pretty_begin
		Time.parse(self.begin).strftime("%l:%M %p") if self.begin
	end

	def pretty_end
		Time.parse(self.end).strftime("%l:%M %p") if self.end
	end
end