class AddOpenToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :open, :boolean
  end
end
