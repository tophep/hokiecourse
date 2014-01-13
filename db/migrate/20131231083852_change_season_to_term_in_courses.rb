class ChangeSeasonToTermInCourses < ActiveRecord::Migration
  def change
  	rename_column :courses, :season, :term
  end
end
