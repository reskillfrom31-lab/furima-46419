FactoryBot.define do
  factory :item do
    #associations
    association :user

    #validations
    #金額指定
    price{ Faker::Number.between(from: 300, to: 9999999) }

    #文字数制限はitem_spec.rbに記載

    #空欄不可
    after(:build) do |message|
      message.image.attach(io: File.open('public/images/test_image.png'), filename: 'test_image.png')
    end
    item_name{ Faker::Lorem.characters(number: 40) }
    item_info{ Faker::Lorem.characters(number: 1000) }
    
    #active::hash
    category_id   { Faker::Number.between(from: 1, to: 10) } 
    status_id     { Faker::Number.between(from: 1, to: 6) }
    fee_id        { Faker::Number.between(from: 1, to: 2) }
    prefecture_id { Faker::Number.between(from: 1, to: 47) } 
    schedule_id   { Faker::Number.between(from: 1, to: 3) }

  end
end
