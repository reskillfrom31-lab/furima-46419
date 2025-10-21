FactoryBot.define do
  factory :address do
    # association
    association :order

    # validation
    postal_code { Faker::Number.number(digits: 3) + '-' + Faker::Number.number(digits: 4)}
    prefecture_id { Faker::Number.between(from: 1, to: 47) } 
    city { Faker::Address.city }
    addresses { Faker::Address.street_address }
    phone { Faker::Phone.number(digits: 11) }
  end
end
