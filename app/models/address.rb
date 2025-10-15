class Address < ApplicationRecord
  # association
  belongs_to :order
  belongs_to :prefecture
end
