class RandHotelJob < ApplicationJob
  queue_as :default

  def perform(*args)
    hotel_params = [{name: Faker::Name.name,
      address: Faker::Address.full_address,
      phone: Faker::PhoneNumber.cell_phone,
      intro: Faker::Lorem.paragraph,
      url: Faker::Internet.url,
      longitude: Faker::Address.longitude,
      latitude: Faker::Address.latitude,
      category: Faker::Company.type }]
    @hotel = Hotel.create!(hotel_params)
  end
end
