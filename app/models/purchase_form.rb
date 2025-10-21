class PurchaseForm

  include ActiveModel::Model
  attr_accessor :user_id, :item_id, :token,
  :postal_code,
  :prefecture_id,
  :city,
  :addresses,
  :building,
  :phone
  
  # ここにバリデーションの処理を書く
  with_options presence: true do
    #紐づけ
    validates :user_id
    validates :item_id

    # 支払い情報
    validates :token

    #住所
    validates :postal_code, format: {
      with: /\A\d{3}-\d{4}\z/,
      message: "is invalid. Include hyphen(-)"
    }
    validates :city
    validates :addresses
    validates :phone, format: {
      with: /\A\d+\z/,
      message: "is invalid. Input only number"
    }
  end
  validates :prefecture_id, numericality: {other_than: 0, message: "can't be blank"}
  validates :phone, length: { in: 10..11, message: 'must be 10 or 11 digits' }, allow_blank: true

  def save
    # 各テーブルにデータを保存（下記rescue条件ではバリデーションエラーのままデータベースが作成されてしまう）
    # ﾊﾞﾝﾒｿｯﾄﾞ「!」を記述することで、エラーが起きてもデータベースが保存されず、エラーメッセージがビューに表記される。）
    ActiveRecord::Base.transaction do
      order = Order.create!(item_id: item_id, user_id: user_id)
      Address.create!(order_id: order.id,
        postal_code: postal_code,
        prefecture_id: prefecture_id,
        city: city,
        addresses: addresses,
        building: building,
        phone: phone
      )
    end
  end
end
