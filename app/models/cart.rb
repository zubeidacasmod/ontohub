class Cart < ActiveRecord::Base
  has_many :cart_items, :dependent => :destroy
  
  def empty?
    cart_items.empty?
  end
  
  def add(item)
    cart_items.create(cart: self, cartable: item)
  end
  
  def size
    cart_items.count
  end
  
  def find(item)
    return cart_items.where(cartable_id: item).first if item.class.to_s == 'Fixnum'
    return cart_items.where(cartable_id: item.id).first
  end
end