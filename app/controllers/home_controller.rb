class HomeController < ApplicationController

  def scheduler
  end

  def submit
  	@cc_count = params["cc_count"]
    @ccs = []
    @cc_count.to_i.times {|i| @ccs << params["cc_" + i.to_s]}

    @crn_count = params["crn_count"]
    @crns = []
    @crn_count.to_i.times {|i| @crns << params["crn_" + i.to_s]}

    render "home/scheduler"
  end
end