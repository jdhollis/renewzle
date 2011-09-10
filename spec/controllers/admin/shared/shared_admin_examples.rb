shared_examples_for "an admin controller" do
  describe "when user is an admin" do
    before(:each) do
      setup_valid_login_credentials_for(Administrator)
      setup_shared_stubs
    end

    it "should set the timezone for the current user" do
      Time.should_receive(:zone=).with(@time_zone)
      do_action
    end
  end
  
  describe "when user is not an admin" do
    before(:each) do
      setup_valid_login_credentials_for(User)
    end
  	
    it "should set session[:destination_url] to the user's original destination" do
      do_action
      session[:destination_url].should == request.env['REQUEST_URI']
    end
  	
    it "should set flash[:notice] to 'Please log in before we send you along to \#{request.env['REQUEST_URI']}.'" do
      do_action
      flash[:notice].should == 'Please log in before we send you along to ' + request.env['REQUEST_URI'] + '.'
    end
  	
    it "should redirect to /login" do
      do_action
      response.should be_redirect
      response.should redirect_to(login_url)
    end
  end
	
  describe "when user is not logged in" do
    it "should set session[:destination_url] to 'request.env['REQUEST_URI']'" do
      do_action
      session[:destination_url].should == request.env['REQUEST_URI']
    end
  	
    it "should set flash[:notice] to 'Please log in before we send you along to \#{request.env['REQUEST_URI']}" do
      do_action
      flash[:notice].should == 'Please log in before we send you along to ' + request.env['REQUEST_URI'] + '.'
    end
  	
    it "should redirect to /login" do
      do_action
      response.should be_redirect
      response.should redirect_to(login_url)
    end
  end
end
