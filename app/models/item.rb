class Item < ApplicationRecord
  
  #associations
  belongs_to :user
  has_one_attached :image
  validates :image, presence: { message: "can't be blank" }

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :category
  belongs_to :status
  belongs_to :fee
  belongs_to :prefecture
  belongs_to :schedule

  #validations
  
  # 空欄不可
  validates :price, 
    presence: { message: "can't be blank(only_integer from 300 to 9999999)" },
    numericality: {
    only_integer: true,
    greater_than_or_equal_to: 300,
    less_than_or_equal_to: 9_999_999,
    message: "can't be blank(only_integer from 300 to 9999999)"
  }

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