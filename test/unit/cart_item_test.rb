require 'test_helper'

class CartItemTest < ActiveSupport::TestCase
  context 'Associations' do
    should belong_to :cart
  end
  
  
end