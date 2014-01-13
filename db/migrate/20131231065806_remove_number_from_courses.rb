class RemoveNumberFromCourses < ActiveRecord::Migration
  def change
    remove_column :courses, :number
  end
end
