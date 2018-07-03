FactoryBot.define do
    factory :activity do
      name { Faker::Name.name }
      address { Faker::Address.full_address }
      phone { Faker::PhoneNumber.cell_phone }
      intro { Faker::Lorem.paragraph }
      url { Faker::Internet.url }
      longitude { Faker::Address.longitude }
      latitude { Faker::Address.latitude }
      category { Faker::Company.type }
    end
  end