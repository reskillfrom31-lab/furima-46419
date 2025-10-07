FactoryBot.define do
  factory :user do
    nickname              { Faker::Name.initials }
    email                 { Faker::Internet.email }
    
    # 🚨 パスワードの要件（英数字混合）を満たす設定
    password              { 'a1' + Faker::Internet.password(min_length: 6) } 
    password_confirmation { password }
    
    # 全角文字の要件を満たす固定値
    last_name             { '山田' } 
    first_name            { '太郎' }
    
    # 全角カタカナの要件を満たす固定値
    last_name_kana        { 'ヤマダ' } 
    first_name_kana       { 'タロウ' }
    
    # 日付型でランダムに生成
    birth_date            { Faker::Date.birthday(min_age: 5, max_age: 90) } 
  end
end