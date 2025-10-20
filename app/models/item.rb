class Item < ApplicationRecord
  
  #associations
  belongs_to :user
  has_one :order
  has_one_attached :image

  def sold_out?
    self.order.present?
  end

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :category
  belongs_to :status
  belongs_to :fee
  belongs_to :prefecture
  belongs_to :schedule

  #validations
  validates :image, presence: { message: "can't be blank" }, unless: :was_attached?
  def was_attached?
    self.image.attached?
  end
  
  # 金額
  validates :price, presence: true
  validates :price, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 300,
    less_than_or_equal_to: 9_999_999,
    message: "is out of setting range or not half-width number"
  }

  # 文字数制限
  validates :item_name, 
    presence: {message: "can't be blank(maximum is 40 characters)"},
    length: { maximum: 40 ,message: "can't be blank(maximum is 40 characters)"}

  validates :item_info,
    presence: {message: "can't be blank(maximum is 1000 characters)"},
    length: { maximum: 1000  ,message: "can't be blank(maximum is 1000 characters)"}
  
  # activehash
  with_options numericality: { other_than: 0, message: "can't be blank" } do
    validates :category_id
    validates :status_id
    validates :fee_id
    validates :prefecture_id
    validates :schedule_id
  end
end