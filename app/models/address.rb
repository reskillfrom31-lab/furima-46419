class Address < ApplicationRecord
  # association
  belongs_to :order
  belongs_to :prefecture

  # validation
  with_options presence: true do
    validates :order_id
    validates :postal_code
    validates :prefecture_id
    validates :city
    validates :addresses
    validates :phone
  end

  validates :postal_code, format: { with: /\A\d{3}-?\d{4}\z/ }
  validates :prefecture_id, numericality: {
    other_than: 0,
    message: "can't be blank"
  }
  validates :phone,
    format: { with: /\A\d{0,11}\z/, message: "is only integer" },
    length: { maximum: 11, message: "maxlength is 11"}
end

