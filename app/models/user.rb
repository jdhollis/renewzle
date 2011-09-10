require 'bcrypt'

class User < ActiveRecord::Base
  include Renewzle::UpdateFrom
  
  has_one :login_token, :dependent => :destroy

  named_scope :recent, :order => 'created_at DESC', :limit => 20
  
  validates_presence_of :first_name
  validates_length_of :first_name, :maximum => 255, :allow_nil => true
  
  validates_presence_of :last_name
  validates_length_of :last_name, :maximum => 255, :allow_nil => true
  
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_length_of :email, :maximum => 255, :allow_nil => true
  validates_format_of :email, :with => /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/, :allow_nil => true
  
  attr_accessor :password
  
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  
  validates_presence_of :hashed_password, :on => :update
  
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :street_address, :city, :state, :postal_code, :phone_number, :fax_number
  
  before_save do |user|
    user.hashed_password = BCrypt::Password.create(user.password) unless user.password.blank?
  end
  
  def self.authenticate(email, password)
    unless email.blank? || password.blank?
      if user = User.find_by_email(email)
        if user.current_password == password
          user
        end
      end
    end
  end
  
  def current_password
    @current_password ||= BCrypt::Password.new(hashed_password)
  end
  
  def login!
    create_login_token
  end

  def logged_in?
    !login_token.blank?
  end
  
  def set_for_password_reset!
	  self.password_reset_key = Digest::MD5.hexdigest(Time.now.to_s + email)
	  save!
	end
	
	def reset_password_to(new_password, new_password_confirmation)
    self.password = new_password
    self.password_confirmation = new_password_confirmation
    self.password_reset_key = nil
    save!
  end

	def full_name
	  "#{first_name} #{last_name}"
	end
	
	def masquerading?
	 false
	end
	
	def masquerading_as?(kind)
	 false
	end
end
