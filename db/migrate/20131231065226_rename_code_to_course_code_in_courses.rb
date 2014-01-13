class RenameCodeToCourseCodeInCourses < ActiveRecord::Migration
  def change
  	rename_column :courses, :code, :course_code
  end
end
