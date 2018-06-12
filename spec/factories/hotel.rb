FactoryBot.define do
    factory :hotel do
      name { Faker::Lorem.sentence }
      address { Faker::Lorem.sentence }
      phone { Faker::Lorem.sentence }
      intro { Faker::Lorem.sentence }
      url { Faker::Lorem.sentence }
      longitude { Faker::Lorem.sentence }
      latitude { Faker::Lorem.sentence }
      category { Faker::Lorem.sentence }
    end
  end