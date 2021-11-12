FactoryBot.define do
    factory :user do
     username {Faker::Name.unique.name }
     email {Faker::Internet.email}
     password {Faker::Internet.password}
    end
end