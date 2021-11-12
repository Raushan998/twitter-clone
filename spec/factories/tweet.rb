FactoryBot.define do
    factory :tweet do
     title {Faker::Lorem.words}
     is_active {true}
     user
    end
end