class Cartable < ActiveRecord::Base
  belongs_to :cart_item, :polymorphic => true
end

