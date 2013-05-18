class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :cartable, :polymorphic => true
  
  attr_accessible :cartable, :cartable_id, :cart, :type
  
end