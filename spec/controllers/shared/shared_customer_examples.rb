shared_examples_for "a controller performing a 'learn' action" do
  it "should set @location to 'learn'" do
    do_action
    assigns[:location].should == 'learn'
  end
end

shared_examples_for "a controller performing an 'explore' action" do
  it "should set @location to 'explore'" do
    do_action
    assigns[:location].should == 'explore'
  end
end

shared_examples_for "a controller performing a 'shop' action" do
  it "should set @location to 'shop'" do
    do_action
    assigns[:location].should == 'shop'
  end
end

shared_examples_for "a controller that recalls a remembered profile or creates a new one" do
  describe "when the user is not logged in" do
    describe "and the user has no remembered profile" do
      before(:each) do
        @profile = mock_model(Profile)
        Profile.should_receive(:new).and_return(@profile)
      end
      
      it "should set @profile to a new profile" do
        do_action
        assigns[:profile].should be(@profile)
      end
    end
    
    describe "and the user has a valid remembered profile" do
      before(:each) do
        setup_remembered_profile
      end
      
      it "should set @profile to the remembered profile" do
        do_action
        assigns[:profile].should be(@profile)
      end
    end
    
    describe "and the user has an invalid remembered profile" do
      before(:each) do
        request.cookies['remembered_profile_id'] = '1'
        Profile.should_receive(:find_unowned).with('1').and_return(nil)
        @profile = mock_model(Profile)
        Profile.should_receive(:new).and_return(@profile)
      end
      
      it "should set @profile to a new profile" do
        do_action
        assigns[:profile].should be(@profile)
      end
      
      it "should delete the invalid remembered_profile_id cookie" do
        do_action
        response.cookies['remembered_profile_id'].should be_blank
      end
    end
  end
  
  describe "when the user is logged in" do      
    describe "as a customer" do
      before(:each) do
        setup_valid_login_credentials_for(Customer)
        @profile = mock_model(Profile)
        @user.should_receive(:profile).and_return(@profile)
      end
      
      it "should set @profile to the user's profile" do
        do_action
        assigns[:profile].should be(@profile)
      end

      it "should delete any remembered_profile_id cookie" do
        do_action
        response.cookies['remembered_profile_id'].should be_blank
      end
    end
    
    describe "as anything other than a customer" do
      before(:each) do
        setup_valid_login_credentials_for(User)
      end
      
      describe "and the user has no remembered profile" do
        before(:each) do
          @profile = mock_model(Profile)
          Profile.should_receive(:new).and_return(@profile)
        end

        it "should set @profile to a new profile" do
          do_action
          assigns[:profile].should be(@profile)
        end
      end

      describe "and the user has a valid remembered profile" do
        before(:each) do
          setup_remembered_profile
        end

        it "should set @profile to the remembered profile" do
          do_action
          assigns[:profile].should be(@profile)
        end
      end

      describe "and the user has an invalid remembered profile" do
        before(:each) do
          request.cookies['remembered_profile_id'] = '1'
          Profile.should_receive(:find_unowned).with('1').and_return(nil)
          @profile = mock_model(Profile)
          Profile.should_receive(:new).and_return(@profile)
        end

        it "should set @profile to a new profile" do
          do_action
          assigns[:profile].should be(@profile)
        end

        it "should delete the invalid remembered_profile_id cookie" do
          do_action
          response.cookies['remembered_profile_id'].should be_blank
        end
      end
    end
  end
end

shared_examples_for "a controller that recalls a remembered profile or redirects to new_profile_url" do
  describe "when the user is not logged in" do
    describe "and the user has no remembered profile" do
      it "should redirect to new_profile_url" do
        do_action
        response.should be_redirect
        response.should redirect_to(new_profile_url)
      end
    end
  
    describe "and the user has a valid remembered profile" do
      before(:each) do
        setup_remembered_profile
        stub_additional_methods_on_success
      end
    
      it "should set @profile to the remembered profile" do
        do_action
        assigns[:profile].should be(@profile)
      end
    end
  
    describe "and the user has an invalid remembered profile" do
      before(:each) do
        request.cookies['remembered_profile_id'] = '1'
        Profile.should_receive(:find_unowned).with('1').and_return(nil)
      end
    
      it "should delete the invalid remembered_profile_id cookie" do
        do_action
        response.cookies['remembered_profile_id'].should be_blank
      end
    
      it "should redirect to new_profile_url" do
        do_action
        response.should be_redirect
        response.should redirect_to(new_profile_url)
      end
    end
  end

  describe "when the user is logged in" do      
    describe "as a customer" do
      before(:each) do
        setup_valid_login_credentials_for(Customer)
        @profile = mock_model(Profile)
        @user.should_receive(:profile).and_return(@profile)
        stub_additional_methods_on_success
      end
    
      it "should set @profile to the user's profile" do
        do_action
        assigns[:profile].should be(@profile)
      end

      it "should delete any remembered_profile_id cookie" do
        do_action
        response.cookies['remembered_profile_id'].should be_blank
      end
    end
  
    describe "as anything other than a customer" do
      before(:each) do
        setup_valid_login_credentials_for(User)
      end
    
      describe "and the user has no remembered profile" do
        it "should redirect to new_profile_url" do
          do_action
          response.should be_redirect
          response.should redirect_to(new_profile_url)
        end
      end

      describe "and the user has a valid remembered profile" do
        before(:each) do
          setup_remembered_profile
          stub_additional_methods_on_success
        end

        it "should set @profile to the remembered profile" do
          do_action
          assigns[:profile].should be(@profile)
        end
      end

      describe "and the user has an invalid remembered profile" do
        before(:each) do
          request.cookies['remembered_profile_id'] = '1'
          Profile.should_receive(:find_unowned).with('1').and_return(nil)
        end
      
        it "should delete the invalid remembered_profile_id cookie" do
          do_action
          response.cookies['remembered_profile_id'].should be_blank
        end

        it "should redirect to new_profile_url" do
          do_action
          response.should be_redirect
          response.should redirect_to(new_profile_url)
        end
      end
    end
  end
end

shared_examples_for "a controller performing a customer-only action" do  
  describe "when user is not a customer" do
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