# frozen_string_literal: true

FactoryBot.define do
    factory :photo do
        visibility { false }
        title { Faker.name }
        owner

        after(:build) do |photo|
            photo.image.attach(io: File.open(Rails.root.join('spec/support/images/doggo.jpg')),
                               filename: 'doggo.jpg', content_type: 'image/jpg')
        end
    end

    factory :user, aliases: [:owner] do
        password = Faker::Internet.password(min_length: 8)
        username { Faker::Internet.user_name }
        email { Faker::Internet.email }
        password { password }
        password_confirmation { password }
        email_verified { false }
    end
end
