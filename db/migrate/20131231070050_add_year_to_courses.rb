class AddYearToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :year, :int
  end
end
