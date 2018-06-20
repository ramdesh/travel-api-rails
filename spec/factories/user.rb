
FactoryBot.define do
  factory :user do
    username { Faker::Name.name }
    first_name { Faker::StarWars.character }
    last_name { Faker::StarWars.specie }
    password 'foobar' #{ Faker::Crypto.sha1 }
    phone { Faker::Number.leading_zero_number(10) }
    role 'admin' 
  end
end