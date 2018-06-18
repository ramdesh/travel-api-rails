class RandActivityJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    activity = Activity.new
    activity.name = Faker::Name.first_name
    sleep 2
  end
end
