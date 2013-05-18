class CreateCartItems < ActiveRecord::Migration
  def up
    create_table :cart_items do |t|
      t.references :cart, :null => false
      t.references :cartable, :null => false
      t.string :cartable_type

      t.timestamps :null => false
    end
    change_table :cart_items do |t|
      t.index :cart_id
      t.index :cartable_id, :unique => true
      t.foreign_key :carts
    end
  end

end
