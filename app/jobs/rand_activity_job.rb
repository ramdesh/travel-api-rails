class RandActivityJob < ApplicationJob
  queue_as :default

  def perform(*args)
    activity_params = [{name: Faker::Name.name,
      address: Faker::Address.full_address,
      phone: Faker::PhoneNumber.cell_phone,
      intro: Faker::Lorem.paragraph,
      url: Faker::Internet.url,
      longitude: Faker::Address.longitude,
      latitude: Faker::Address.latitude,
      category: Faker::Company.type }]
    @activity = Activity.create!(activity_params)
  end
end
