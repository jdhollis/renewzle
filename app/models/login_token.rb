require 'digest/sha1'

class LoginToken < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id
  
  before_validation_on_create do |login_token|
    login_token.value = Digest::SHA1.hexdigest("tasty sea salt#{Time.now}$$")
  end
end
