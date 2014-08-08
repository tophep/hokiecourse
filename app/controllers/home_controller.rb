class HomeController < ApplicationController
  include ScheduleBuilder

  def scheduler
    render "home/scheduler"
  end

  def submit
    @term_code = params["term_code"]
    @year = @term_code[0..3]
    @term = @term_code[4..5]
    @earliest = params["earliest"]
    @latest = params["latest"]
    @no8am = params["no8am"]
    @scs = []
    @crns = []

    params["sc_count"].to_i.times do |i|
      code = parse_subject_code(params["sc_" + i.to_s])
      @scs << code if code && !@scs.include?(code)
    end
    @valid_scs = validate_codes(@year, @term, @scs, :subject_code)

    params["crn_count"].to_i.times do |i|
      crn = parse_crn(params["crn_" + i.to_s])
      @crns << crn if crn && !@crns.include?(crn)
    end
    @valid_crns = validate_codes(@year, @term, @crns, :crn)

    if (@valid_scs.size > 0)
      request = {scs:@valid_scs, crns:@valid_crns, no8am:@no8am, 
      earliest:@earliest, latest:@latest, year:@year, term_code:@term}
      @results = build_schedule(request)
    end


    render "home/scheduler"
  end
end

