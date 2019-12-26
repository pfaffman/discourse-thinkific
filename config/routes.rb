require_dependency "discourse_thinkific_constraint"

DiscourseThinkific::Engine.routes.draw do
  get "/" => "discourse_thinkific#index", constraints: DiscourseThinkificConstraint.new
  get "/actions" => "actions#index", constraints: DiscourseThinkificConstraint.new
  get "/actions/:id" => "actions#show", constraints: DiscourseThinkificConstraint.new
end
