class CategoryPayment < ActiveRecord::Base
  belongs_to :category
  belongs_to :payment
end
