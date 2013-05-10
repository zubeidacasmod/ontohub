class Cart < ActiveRecord::Base
  has_many :cart_items, :dependent => :destroy
  
  def empty?
    cart_items.empty?
  end
  
  def add(item)
    cart_items.create(cart: self, ontology_version: item)
  end
  
  def size
    cart_items.count
  end
  
  def find(item)
    return cart_items.where(ontology_version_id: item.id).first if item.class.to_s == 'OntologyVersion'
    return cart_items.where(ontology_version_id: item).first if item.class.to_s == 'Fixnum'
    raise "not acceptable type: " + item.class.to_s
  end
end