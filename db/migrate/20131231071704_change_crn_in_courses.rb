class ChangeCrnInCourses < ActiveRecord::Migration
  def change
  	change_column :courses, :crn, :string
  end
end
