shared_examples_for "a retailer controller" do
	describe "when user is a partner" do
		before(:each) do
			setup_valid_login_credentials_for(Partner)
			setup_shared_stubs
		end
	end

	describe "when user is not a partner" do
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

	describe "when partner is not approved" do
		before(:each) do
      setup_valid_login_credentials_for(Partner)
			@user.stub!(:waiting_approval).and_return(true)
		end

		it "should redirect user to dashboard" do
			do_action
  		response.should be_redirect
  		response.should redirect_to(retailer_dashboard_url)
		end

		it "should set session[:destination_url] to the partner's original destination" do
			do_action
			session[:destination_url].should == request.env['REQUEST_URI']
		end

		it "should set flash[:notice] to 'You must complete the Partner approval process before continuing on to \#{request.env['REQUEST_URI']}'." do
			do_action
			flash[:notice].should == 'You must complete the Partner approval process before continuing on to ' + request.env['REQUEST_URI'] + '.'
		end

		it "should redirect to /partner/dashboard" do
			do_action
			response.should be_redirect
			response.should redirect_to(retailer_dashboard_url)
		end
	end
end
