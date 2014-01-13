namespace :sched_test do
	require_relative "../schedule_maker.rb"

task :test => :environment do
	course_codes = ["CS-2114", "MATH-3034", "CHEM-1036", "MATH-2214", "ENGE-1104"] 
	course_lists = ScheduleMaker.all_course_sections(course_codes)
	ScheduleMaker.generate_all_valid_combos(course_lists)
end

end