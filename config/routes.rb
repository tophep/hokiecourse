Scheduler::Application.routes.draw do
  root "home#scheduler"
  post "/" => "home#submit"

end
