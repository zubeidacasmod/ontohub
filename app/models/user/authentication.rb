module User::Authentication
  
  extend ActiveSupport::Concern
  
  included do
    # Include default devise modules. Others available are:
    # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable, :confirmable,
           :recoverable, :rememberable, :trackable, :validatable,
           :openid_authenticatable
    
    # Setup accessible (or protected) attributes for your model
    attr_accessible :email, :password, :password_confirmation, :remember_me, :name
  end
  
  module ClassMethods
    def build_from_identity_url(identity_url)
      User.new({ identity_url: identity_url}, without_protection: true)
    end
  end
  
  def openid_fields=(fields)
    raise fields.inspect
    fields.each do |key, value|
    end
  end
  
  # display an alert to the user?
  def display_alert?
    !confirmed?
  end
  
end