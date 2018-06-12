FactoryBot.define do
  factory :user do
    username { Faker::StarWars.character }
    first_name { Faker::StarWars.character }
    last_name { Faker::StarWars.specie }
    password { Faker::Crypto.sha1 }
    phone { Faker::Number.leading_zero_number(10) }
    role { Faker::Job.position }
  end
end