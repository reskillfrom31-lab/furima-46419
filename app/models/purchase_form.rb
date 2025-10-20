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
      with: /\A[0-9]{3}-[0-9]{4}\z/,
      message: "is invalid. Include hyphen(-)"
    }
    validates :city
    validates :addresses
    validates :phone, format: {
      with: /\A[0-9]{10,11}\z/,
      message: "is invalid. Enter a half-width number without hyphens."
    }
  end
  validates :prefecture_id, numericality: {other_than: 0, message: "can't be blank"}

  def save
    # 各テーブルにデータを保存（下記rescue条件ではバリデーションエラーのままデータベースが作成されてしまう）
    # ﾊﾞﾝﾒｿｯﾄﾞ「!」を記述することで、エラーが起きてもデータベースが保存されず、エラーメッセージがビューに表記される。）
    ActiveRecord::Base.transaction do
      order = Order.create!(user_id: user_id, item_id: item_id)
      address = Address.create!(order_id: order.id,
        postal_code: postal_code,
        prefecture_id: prefecture_id,
        city: city,
        addresses: addresses,
        building: building,
        phone: phone
      )
    end
    true
  # rescue は ActiveRecord::RecordInvalid (create! の例外) を捕捉
  # full_messagesをﾌｫｰﾑｵﾌﾞｼﾞｪｸﾄの:baseにコピーする
  rescue ActiveRecord::RecordInvalid => e
    e.record.errors.full_messages.each do |message|
      errors.add(:base, message)
    end
    false
  end
end