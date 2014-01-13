class Subject < ActiveRecord::Base

	attr_accessible :name, :abbrev

	has_many :courses
end
