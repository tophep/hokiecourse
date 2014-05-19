class AddTermCodeToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :term_code, :string
  end
end
