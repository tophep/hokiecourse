class CreateAdditionalTimes < ActiveRecord::Migration
  def change
    create_table :additional_times do |t|
      t.string :begin
      t.string :end
      t.string :location
      t.string :days
      t.integer :course_id
      t.integer :order

      t.timestamps
    end
  end
end