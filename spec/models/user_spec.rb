require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before(:each) do
    @user = User.new
  end
  
  it "should have one login_token" do
    @user.should respond_to(:login_token)
  end
  
  it "should have a dependent login_token" do
    @login_token = mock_model(LoginToken)
    @login_token.should_receive(:destroy)
    @user.login_token = @login_token
    @user.destroy
  end
  
  it "should require a first name" do
    @user.should have(1).error_on(:first_name)
    @user.first_name = 'J.D.'
    @user.should have(:no).errors_on(:first_name)
  end
  
  it "should require a first name that is less than or equal to 255 characters in length" do
    long_first_name = ''
    0.upto(256) { |i| long_first_name << i.to_s  }
    @user.first_name = long_first_name
    @user.should have(1).error_on(:first_name)
    @user.errors.on(:first_name).should == 'is too long (maximum is 255 characters)'
  end
  
  it "should allow first_name to be changed via mass-assignment" do
    @user.first_name.should be_blank
    @user.attributes = { :first_name => 'J.D.' }
    @user.first_name.should == 'J.D.'
  end
  
  it "should require a last name" do
    @user.should have(1).error_on(:last_name)
    @user.last_name = 'Hollis'
    @user.should have(:no).errors_on(:last_name)
  end
  
  it "should require a last name that is less than or equal to 255 characters in length" do
    long_last_name = ''
    0.upto(256) { |i| long_last_name << i.to_s  }
    @user.last_name = long_last_name
    @user.should have(1).error_on(:last_name)
    @user.errors.on(:last_name).should == 'is too long (maximum is 255 characters)'
  end
  
  it "should allow last_name to be changed via mass-assignment" do
    @user.last_name.should be_blank
    @user.attributes = { :last_name => 'Hollis' }
    @user.last_name.should == 'Hollis'
  end
  
  it "should require an email address" do
    @user.should have(1).error_on(:email)
    @user.email = 'jd@greenoptions.com'
    @user.should have(:no).errors_on(:email)
  end
  
  it "should require a unique email address" do
    @another_user = User.create(:first_name => 'J.D.', :last_name => 'Hollis', :email => 'jd@greenoptions.com', :password => 'password')
    @user.email = 'jd@greenoptions.com'
    @user.should have(1).error_on(:email)
    @user.errors.on(:email).should == 'has already been taken'
  end
  
  it "should require an email address that is less than or equal to 255 characters in length" do
    long_email = 'jd@'
    0.upto(256) { |i| long_email << i.to_s  }
    long_email << '.net'
    @user.email = long_email
    @user.should have(1).error_on(:email)
    @user.errors.on(:email).should == 'is too long (maximum is 255 characters)'
  end
  
  it "should require an email address that looks like an email address" do
    @user.email = 'get frelled'
    @user.should have(1).error_on(:email)
    @user.errors.on(:email).should == 'is invalid'
    @user.email = 'jd@morning-memories.net'
    @user.should have(:no).errors_on(:email)
  end
  
  it "should allow email to be changed via mass-assignment" do
    @user.email.should be_blank
    @user.attributes = { :email => 'jd@greenoptions.com' }
    @user.email.should == 'jd@greenoptions.com'
  end
  
  it "should require a password on create" do
    @user.should have(1).error_on(:password)
    @user.password = 'password'
    @user.should have(:no).errors_on(:password)
  end
  
  it "should allow password (and password_confirmation) to be changed via mass-assignment" do
    @user.password.should be_blank
    @user.password_confirmation.should be_blank
    @user.attributes = { :password => 'password', :password_confirmation => 'password' }
    @user.password.should == 'password'
    @user.password_confirmation.should == 'password'
  end
  
  it "should not allow hashed_password to be changed via mass-assignment" do
    setup_valid_user
    @user.attributes = { 'hashed_password' => 'get frelled' }
    @user.hashed_password.should_not == 'get frelled'
  end
  
  describe "when password is not blank" do
    before(:each) do
      @user.first_name = 'J.D.'
      @user.last_name = 'Hollis'
      @user.email = 'jd@greenoptions.com'
      @password = 'password'
      @user.password = @password
    end
    
    it "should require password confirmation" do
      @user.password_confirmation = 'not_the_password'
      @user.should have(1).error_on(:password)
      @user.password_confirmation = @password
      @user.should have(:no).errors_on(:password)
    end
    
    it "should set hashed_password to a bcrypt-encrypted password on save" do
      @user.password_confirmation = @password
      BCrypt::Password.should_receive(:create).with(@password).and_return('hashed password')
      @user.save!
      @user.hashed_password.should == 'hashed password'
    end
  end
  
  describe "when password is blank" do
    before(:each) do
      @user.first_name = 'J.D.'
      @user.last_name = 'Hollis'
      @user.email = 'jd@greenoptions.com'
      @user.password = 'password'
      @user.password_confirmation = 'password'
      BCrypt::Password.stub!(:create).and_return('hashed password')
      @user.save!
    end
    
    it "should not touch hashed_password" do
      @user.password = nil
      @user.password_confirmation = nil
      BCrypt::Password.should_not_receive(:create)
      @original_hashed_password = @user.hashed_password
      @user.save!
      @user.hashed_password.should == @original_hashed_password
    end
  end
  
  it "should require a hashed password on update" do
    @user.first_name = 'J.D.'
    @user.last_name = 'Hollis'
    @user.email = 'jd@greenoptions.com'
    @user.password = 'password'
    @user.password_confirmation = 'password'
    @user.should be_valid
    @user.save!
    @user.hashed_password = nil
    @user.should have(1).error_on(:hashed_password)
  end
  
  it "should allow street_address to be changed via mass-assignment" do
    @user.street_address.should be_blank
    @user.attributes = { :street_address => '3003 Benham Avenue' }
    @user.street_address.should == '3003 Benham Avenue'
  end
  
  it "should allow city to be changed via mass-assignment" do
    @user.city.should be_blank
    @user.attributes = { :city => 'Elkhart' }
    @user.city.should == 'Elkhart'
  end
  
  it "should allow state to be changed via mass-assignment" do
    @user.state.should be_blank
    @user.attributes = { :state => 'IN' }
    @user.state.should == 'IN'
  end
  
  it "should allow postal_code to be changed via mass-assignment" do
    @user.postal_code.should be_blank
    @user.attributes = { :postal_code => '46517' }
    @user.postal_code.should == '46517'
  end
  
  it "should allow phone_number to be changed via mass-assignment" do
    @user.phone_number.should be_blank
    @user.attributes = { :phone_number => '+1 574 304 1187' }
    @user.phone_number.should == '+1 574 304 1187'
  end
  
  it "should allow fax_number to be changed via mass-assignment" do
    @user.fax_number.should be_blank
    @user.attributes = { :fax_number => '+1 574 304 1187' }
    @user.fax_number.should == '+1 574 304 1187'
  end
  
  describe "#authenticate" do
    describe "when not provided with an email address" do
      it "should return nil" do
        User.authenticate(nil, 'password').should be(nil)
      end
    end
    
    describe "when not provided with a password" do
      it "should return nil" do
        User.authenticate('jd@greenoptions.com', nil).should be(nil)
      end
    end
    
    describe "when provided with an invalid email" do
      it "should return nil" do
        @email = 'jd@greenoptions.com'
        User.should_receive(:find_by_email).with(@email).and_return(nil)
        User.authenticate(@email, 'password').should be(nil)
      end
    end
    
    describe "when provided with a valid email and an invalid password" do
      it "should return nil" do
        setup_valid_user
        User.should_receive(:find_by_email).with(@email).and_return(@user)
        @bcrypt_password.should_receive(:==).with('invalid').and_return(false)
        User.authenticate(@email, 'invalid').should be(nil)
      end
    end
    
    describe "when provided with a valid email and valid password" do
      it "should return the appropriate user" do
        setup_valid_user
        User.should_receive(:find_by_email).with(@email).and_return(@user)
        @bcrypt_password.should_receive(:==).with(@password).and_return(true)
        User.authenticate(@email, @password).should be(@user)
      end
    end
  end
  
  describe "#login!" do
    it "should create and return a new login token" do
      @login_token = mock_model(LoginToken)
      @user.should_receive(:create_login_token).and_return(@login_token)
      @user.login!.should be(@login_token)
    end
  end
  
  describe "#set_for_password_reset!" do
    before(:each) do
      @user = User.new(:email => 'jd@greenoptions.com')
      Digest::MD5.should_receive(:hexdigest).and_return('12345abcd')
    end
    
    it "should set :password_reset_key to Digest::MD5.hexdigest(Time.now.to_s + email)" do
      @user.stub!(:save!)
      @user.set_for_password_reset!
      @user.password_reset_key.should == '12345abcd'
    end
    
    it "should save! the user" do
      @user.should_receive(:save!)
      @user.set_for_password_reset!
    end
  end
  
  describe "#reset_password_to" do
    before(:each) do
      @user = User.new
      @password = 'password'
      @password_confirmation = 'password_confirmation'
    end
    
    it "should set :password to the new password" do
      @user.stub!(:save!)
      @user.reset_password_to(@password, @password_confirmation)
      @user.password.should == @password
    end
    
    it "should set :password_confirmation to the password confirmation" do
      @user.stub!(:save!)
      @user.reset_password_to(@password, @password_confirmation)
      @user.password_confirmation.should == @password_confirmation
    end
    
    it "should set :password_reset_key to nil" do
      @user.stub!(:save!)
      @user.reset_password_to(@password, @password_confirmation)
      @user.password_reset_key.should be_nil
    end
    
    it "should save! the user" do
      @user.should_receive(:save!)
      @user.reset_password_to(@password, @password_confirmation)
    end
  end
  
  describe "#update_from" do
    before(:each) do
      @params = { 'id' => '1' }
    end
    
    it "should set attributes to params" do
      @user.should_receive(:attributes=).with(@params)
      @user.stub!(:save!)
      @user.update_from(@params)
    end
    
    it "should save! the user" do
      @user.stub!(:attributes=)
      @user.should_receive(:save!)
      @user.update_from(@params)
    end
  end
  
  describe "#logged_in?" do
    it "should return true if login_token is set" do
      setup_valid_user
      @user.login_token = mock_model(LoginToken)
      @user.should be_logged_in
    end

    it "should return false if login_token is not set" do
      setup_valid_user
      @user.should_not be_logged_in
    end
  end
  
  describe "#full_name" do
    it "should return first_name and last_name separated by a space" do
      setup_valid_user
      @user.full_name.should == "#{@user.first_name} #{@user.last_name}"
    end
  end
  
  describe "#masquerading?" do
    it "should return false" do
      @user.masquerading?.should be(false)
    end
  end
  
  describe "#masquerading_as? with a User type" do
    it "should return false" do
      @user.masquerading_as?(Customer).should be(false)
      @user.masquerading_as?(Partner).should be(false)
    end
  end
  
  def setup_valid_user
    @first_name = 'J.D.'
    @last_name = 'Hollis'
    @email = 'jd@greenoptions.com'
    @password = 'password'
    @user.first_name = @first_name
    @user.last_name = @last_name
    @user.email = @email
    @user.password = @password
    @user.password_confirmation = @password
    @hashed_password = 'hashed password'
    BCrypt::Password.stub!(:create).and_return(@hashed_password)
    @bcrypt_password = mock('bcrypt password')
    BCrypt::Password.stub!(:new).and_return(@bcrypt_password)
  end
end
