require File.dirname(__FILE__) + '/../spec_helper'

describe Notifier do
	describe "#forgot_password" do
  	it "should provide a reset url" do
			@user = mock_model(User)
			@user.should_receive(:email)
			@user.should_receive(:password_reset_key).and_return('12345')
    	Notifier.deliver_forgot_password(@user)
  	end
	end
end
