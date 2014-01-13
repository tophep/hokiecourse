class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.integer :crn
      t.integer :number
      t.string :title
      t.integer :cred_hours
      t.string :instructor
      t.string :begin
      t.string :end
      t.string :location
      t.integer :subject_id
      t.boolean :online
      t.string :days
      t.string :semester_code

      t.timestamps
    end
  end
end
