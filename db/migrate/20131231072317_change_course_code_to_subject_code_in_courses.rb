class ChangeCourseCodeToSubjectCodeInCourses < ActiveRecord::Migration
  def change
  	rename_column :courses, :course_code, :subject_code
  end
end
