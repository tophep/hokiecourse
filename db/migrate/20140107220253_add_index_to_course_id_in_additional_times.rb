class AddIndexToCourseIdInAdditionalTimes < ActiveRecord::Migration
  def change
  	add_index :additional_times, :course_id, :name => 'course_id_ix'
  end
end
