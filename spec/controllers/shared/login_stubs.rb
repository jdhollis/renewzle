module LoginStubs
  def setup_valid_login_credentials_for(kind)
    login_token_value = mock('login_token_value')
    request.cookies['login_token_value'] = login_token_value
    @login_token = mock_model(LoginToken)
    LoginToken.should_receive(:find_by_value).with(login_token_value).and_return(@login_token)

    @user = mock_model(kind)
    
    @user.stub!(:masquerading_as?).and_return(false)
    
    case kind.to_s
    when "Administrator"
      @time_zone = mock('time zone')
  	  @user.stub!(:time_zone).and_return(@time_zone)
    when "Partner"
	    @user.stub!(:waiting_approval).and_return(false)
  	  @user.stub!(:can_update_company_profile).and_return(true)
    end
    
    @login_token.should_receive(:user).and_return(@user)
  end
end
