class ChangeYearToStringInCourses < ActiveRecord::Migration
  def change
  	change_column :courses, :year, :string
  end
end
