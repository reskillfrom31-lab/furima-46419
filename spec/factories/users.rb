FactoryBot.define do
  factory :user do
    nickname              { 'hogehoge1' }
    email                 { 'hogehoge1@gmail.com' }
    
    # 🚨 パスワードの要件（英数字混合）を満たす設定
    password              { 'hogehoge1' } 
    password_confirmation { 'hogehoge1' }
    
    # 全角文字の要件を満たす固定値
    last_name             { 'ほげほげ' } 
    first_name            { 'いちろう' }
    
    # 全角カタカナの要件を満たす固定値
    last_name_kana        { 'ホゲホゲ' } 
    first_name_kana       { 'イチロウ' }
    
    # 日付型でランダムに生成
    birth_date {'2000-01-01'}
    #birth_date            { Faker::Date.birthday(min_age: 5, max_age: 90) } 
  end
end