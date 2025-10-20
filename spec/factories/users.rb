FactoryBot.define do
  factory :user do
    nickname              { Faker::Name.initials(number: 2) }
    sequence(:email) { |n| "test#{n}@example.com" }
    
    # 🚨 パスワードの要件（英数字混合）を満たす設定
    password              { 'a1' + Faker::Internet.password(min_length: 6) } 
    password_confirmation { password }    

    # 全角文字の要件を満たす固定値
    last_name             { Gimei.last.kanji } 
    first_name            { Gimei.first.kanji }
    
    # 全角カタカナの要件を満たす固定値
    last_name_kana        { Gimei.last.katakana } 
    first_name_kana       { Gimei.first.katakana }
    
    # 日付型でランダムに生成
    birth_date {Faker::Date.birthday(min_age: 18, max_age: 60)}
    #birth_date            { Faker::Date.birthday(min_age: 5, max_age: 90) } 
  end
end