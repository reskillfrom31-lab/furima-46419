class PurchaseForm
  include ActiveModel::model # バリデーション機能などを利用可能にする
  # フォームで扱う属性を定義する
  attr_accessor :token,
    # 売買関係
    :user_id,
    :item_id,
    # アドレスモデルに記載
    :postal_code,
    :prefecture_id,
    :city,
    :addresses,
    :building,
    :phone

  # バリデーション
  validates :token, presence: true

  def save
    ActiveRecord::Base.transaction do
      order=Order.create!(
        user_id: self.user_id,
        item_id: self.item_id
      )

      Address.create!(
        order_id: order.id,
        postal_code: self.postal_code,
        prefecture_id: self.prefecture_id,
        city: self.city,
        addresses: self.addresses,
        building: self.building,
        phone: self.phone
      )
    end

    true
  rescue Payjp::PayjpError => e
    errors.add("PAY.JP Error: #{e.message}}")
    false
  rescue => e
    Rails.logger.error("PurchaseForm save failed: #{e.message}")
    false
  end
end
  