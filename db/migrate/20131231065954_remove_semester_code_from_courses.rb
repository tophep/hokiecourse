class RemoveSemesterCodeFromCourses < ActiveRecord::Migration
  def change
  	remove_column :courses, :semester_code
  end
end
