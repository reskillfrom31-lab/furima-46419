FactoryBot.define do
  factory :purchase_form do

    # 必須属性
    token           { 'tok_abcdefghijk00000000000000000' } # ダミーのPAYJPトークン
    postal_code     { '123-4567' }
    prefecture_id   { 1 } # 0以外
    city            { '渋谷区' }
    addresses       { '1-1-1' }
    phone           { '09012345678' }

    # 任意属性
    building        { '建物名' }
  end
end