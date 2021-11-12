FactoryBot.define do
    factory :comment do
     title {Faker::Lorem.words}
     is_active {true}
     user
     tweet
    end
end