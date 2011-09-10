require File.dirname(__FILE__) + '/../spec_helper'

describe LoginToken do
  before(:each) do
    @login_token = LoginToken.new
  end
  
  it "should belong to a User" do
    @login_token.should respond_to(:user)
  end
  
  it "should require the presence of a user_id" do
    @login_token.should have(1).error_on(:user_id)
    @login_token.user_id = 1
    @login_token.should have(:no).errors_on(:user_id)
  end
  
  it 'should set :value to Digest::SHA1.hexdigest("tasty sea salt#{Time.now}$$") before validation on create' do
    @login_token.value.should be_blank
    Digest::SHA1.should_receive(:hexdigest).and_return('value')
    @login_token.save
    @login_token.value.should == 'value'
  end
end