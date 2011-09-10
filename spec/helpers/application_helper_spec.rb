require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  include ApplicationHelper

  describe "#server_name" do
    it "should return 'renewzle.com' if ENV['SERVER_DOMAIN'] is not set" do
      server_name.should == 'www.renewzle.com'
    end

    it "should return ENV['SERVER_DOMAIN'] if ENV['SERVER_DOMAIN'] is set" do
      ENV['SERVER_DOMAIN'] = 'staging.renewzle.com'
      server_name.should == 'staging.renewzle.com'
    end
    
    after(:each) do
      ENV['SERVER_DOMAIN'] = nil
    end
  end
  
  describe "#message_from" do
    [ :warning, :notice, :message ].each do |message_type|
      it "should return a paragraph of class .#{message_type} containing a #{message_type} when flash[:#{message_type}] is set" do
        @mock_flash = { message_type => "A #{message_type}." }
        message_from(@mock_flash).should == content_tag('p', "A #{message_type}.", :class => message_type.to_s)
      end
    end
    
    it "should only print 1 message type at a time (even if there are others set)" do
      @mock_flash = { :warning => 'A warning.', :notice => 'A notice.' }
      message_from(@mock_flash).should == content_tag('p', "A warning.", :class => 'warning')
    end
  end
  
  describe "#in_production?" do
    it "should return true if ENV['RAILS_ENV'] == 'production'" do
      ENV['RAILS_ENV'] = 'production'
  		in_production?.should be(true)
    end
    
    it "should return false if ENV['RAILS_ENV'] != 'production'" do
      in_production?.should be(false)
    end
    
    after(:each) do
      ENV['RAILS_ENV'] = 'test'
    end
  end

	describe "#page_javascript" do
	  it "should return a script tag containing javascript set in @page_javascript" do
			@page_javascript = []
			@page_javascript << "document.write('Hello World');"
			page_javascript.should == javascript_tag(@page_javascript.uniq.join('\n'))
	  end
	end
	
	describe "#separator" do
		it "should return span of class separator containing the text '|'" do
			separator.should == content_tag('span', '|', :class => 'separator')
		end
	end

	describe "#meta_description" do
		it "should return a meta tag containing the text set in @meta_description" do
			@meta_description = 'meta description'
			meta_description.should == tag('meta', :name => 'description', :content => h(@meta_description))
		end
	end
	
	describe "#meta_keywords" do
		it "should return a meta tag containing the text set in @meta_keywords" do
			@meta_keywords = 'meta keywords'
			meta_keywords.should == tag('meta', :name => 'keywords', :content => h(@meta_keywords))
		end
	end

	describe "#view_title" do
		it "should return the text (Renezle.com) for the view title when @view_title is blank" do
			view_title.should == 'Renewzle.com'
		end

		it "should return text for the view title when @view_title is set" do
			@view_title = 'My Profile'
			view_title.should == "#{@view_title} &mdash; Renewzle.com"
		end
	end

	describe "#mint" do
		it "should return javascript for mint resource" do
			self.should_receive(:render).and_return('rendering')
			self.should_receive(:in_production?).and_return(true)
			mint.should == 'rendering'
		end
	end

	describe "#google_analytics" do
		it "should return javascript for google analytics resource" do
			self.should_receive(:render).and_return('rendering')
			self.should_receive(:in_production?).and_return(true)
			google_analytics.should == 'rendering'
		end
	end

	describe "#dom_id_from" do
		it "should return an empty string when string is blank?" do
			dom_id_from('').should == ''
		end

		it "should return markup when string is not blank?" do
			dom_id_from('profile').should == ' id="profile"'
		end
	end

	describe "#home_url" do
    describe "when the user is not logged in" do
      describe "and the user has no profile" do
        it "should return learn_url" do
          home_url.should == learn_url
        end
      end
      
      describe "and the user has a profile but has not progressed to the Explore stage" do
        before(:each) do
          @profile = mock_model(Profile)
          @profile.should_receive(:getting_started?).and_return(true)
        end
        
        it "should return learn_url" do
          home_url.should == learn_url
        end
      end
      
      describe "and the user has a profile and has progressed to the Explore stage" do
        before(:each) do
          @profile = mock_model(Profile)
          @profile.should_receive(:getting_started?).and_return(false)
        end
        
        it "should return explore_url" do
          home_url.should == explore_url
        end
      end
    end
    
    describe "when the user is logged in" do
      describe "as a Customer" do
        before(:each) do
          @user = mock_model(Customer)
          @user.should_receive(:masquerading?).and_return(false)
        end
        
        describe "without a profile" do
          before(:each) do
            @user.should_receive(:profile).and_return(nil)
          end
          
          it "should return learn_url" do
            home_url.should == learn_url
          end
        end
        
        describe "with a profile" do
          before(:each) do
            @profile = mock_model(Profile)
            @user.should_receive(:profile).and_return(@profile)
          end
          
          describe "and the customer has not progressed beyond the Learn stage" do
            before(:each) do
              @profile.should_receive(:getting_started?).and_return(true)
            end

            it "should return learn_url" do
              home_url.should == learn_url
            end
          end

          describe "and the customer has progressed to the Explore stage" do
            before(:each) do
              @profile.should_receive(:getting_started?).and_return(false)
              @profile.should_receive(:rfq?).and_return(false)
            end

            it "should return explore_url" do
              home_url.should == explore_url
            end
          end

          describe "and the customer has submitted the profile as an RFQ (progressing to the Shop stage)" do
            before(:each) do
              @profile.should_receive(:getting_started?).and_return(false)
              @profile.should_receive(:rfq?).and_return(true)            
            end

            it "should return shop_url" do
              home_url.should == shop_url
            end
          end
        end
      end
      
      describe "as a Partner" do
        before(:each) do
          @user = mock_model(Partner)
          @user.should_receive(:masquerading?).and_return(false)
        end
        
        it "should return retailer_dashboard_url" do
          home_url.should == retailer_dashboard_url
        end
      end
      
      describe "as an Administrator" do
        before(:each) do
          @user = mock_model(Administrator)
          @user.should_receive(:masquerading?).and_return(false)
        end
        
        it "should return admin_dashboard_url" do
          home_url.should == admin_dashboard_url
        end
      end
    end
	end

	describe "#loading_span_of_size" do
		it "should return markup without span id" do
			loading_span_of_size(25, {}).should == content_tag('span', image_tag('loading.gif', :alt => 'loading indicator', :height => 25, :width => 25), :id => nil, :class => 'loading', :style => 'display:none')
		end

		it "should return markup with span id for a string" do
			@for = 'quotes'
			loading_span_of_size(25, { :for => @for }).should == content_tag('span', image_tag('loading.gif', :alt => 'loading indicator', :height => 25, :width => 25), :id => 'quotes_loading', :class => 'loading', :style => 'display:none')
		end

		it "should return markup with span id for non string object" do
			@for = mock('quote')
			self.should_receive(:dom_id).with(@for).and_return('')
			loading_span_of_size(25, { :for => @for }).should == content_tag('span', image_tag('loading.gif', :alt => 'loading indicator', :height => 25, :width => 25), :id => '', :class => 'loading', :style => 'display:none')
		end
	end

	describe "#my_account_link" do
		it "should return a li with a link labelled 'My Account' for a Customer when user is a customer" do
			@user = mock_model(Customer)
			@user.should_receive(:masquerading?).and_return(false)
			self.stub!(:separator).and_return('')
			self.should_receive(:account_url).and_return('')
			my_account_link.should == content_tag('li', li_contents = link_to('My Account', '', :title => 'Edit my account information') + '', { :class => 'my_account' })
		end
	
		it "should return a li with a link labelled 'My Account' for a Partner when user is a customer" do
			@user = mock_model(Partner)
			@user.should_receive(:masquerading?).and_return(false)
			self.stub!(:separator).and_return('')
			self.should_receive(:retailer_account_url).and_return('')
			my_account_link.should == content_tag('li', li_contents = link_to('My Account', '', :title => 'Edit my account information') + '', { :class => 'my_account' })
		end
	end

	describe "#login_logout_link" do
		it "should return a link to 'login_url' when @user is not logged in" do
			@user = nil
			login_logout_link.should == content_tag('li', link_to('Login', login_url), { :id => 'login_link' })
		end
		
		it "should return a link to 'logout_url' when @user is logged in" do
			@user = mock_model(User)
			@user.should_receive(:masquerading?).and_return(false)
			login_logout_link.should == content_tag('li', link_to('Logout', logout_url), {})
		end
		
		it "should return a link to 'stop_masquerading' when @user is logged in and masquerading" do
		  @user = mock_model(User)
		  @user.should_receive(:masquerading?).and_return(true)
		  login_logout_link.should == content_tag('li', link_to('Logout', stop_masquerading_url), {})
		end
	end

	describe "#number_to_accounting" do
		describe "when number is > 0" do
			it "should return a formatted number using the defaults" do
				number_to_accounting(100).should == '$100.00'
			end
		end

		describe "when number is < 0" do
			it "should return a formatted number using the defaults" do
				number_to_accounting(-100).should == content_tag('span', '$(100.00)', :class => 'negative')
			end
		end

		it "should return use passed value" do
			number_to_accounting(100, :precision => 6).should == "$100.000000"
		end

		it "should use the passed value" do
			number_to_accounting(100, :unit => '$%^&').should == "$%^&100.00"
		end

		describe "separator" do
			describe "when precision is > 0" do
				it "should return a formatted number with the passed separator" do
		 			number_to_accounting(100, :separator => ':', :precision => 2).should == "$100:00"
				end
			end

			describe "when precision is <= 0" do
				it "should return a formatted number with the passed separator" do
		 			number_to_accounting(100, :separator => ':', :precision => 0).should == "$100"
				end
			end
		end

		it "should return a formatted number with the passed delimiter" do
			number_to_accounting(1000, :delimiter => ':').should == "$1:000.00"
		end

		it "should return the number when an error occurs" do
			number_to_accounting('100').should == '100'
		end
	end

	describe "#number_with_delimiter_and_parens" do
		describe "when number is less than zero" do
			it "should return a formatted number" do
				number_with_delimiter_and_parens(-1000.0).should == content_tag('span', '(1,000.0)', :class => 'negative')
			end
		end

		describe "when number is greater than zero" do
			it "should return a formatted number" do
				number_with_delimiter_and_parens(1000.0).should == '1,000.0'
			end
		end
	end

	describe "#initial_visit" do
		it "should return true if :user and :profile is blank?" do
			@user = nil
			@profile = nil
			initial_visit?.should == true
		end

		it "should return false if :user is not blank?" do
			@user = stub_model(User)
			@profile = nil
			initial_visit?.should == false
		end

		it "should return false if :profile is not blank?" do
			@user = nil
			@profile = stub_model(Profile)
			initial_visit?.should == false
		end
	end

	[ 'learn', 'explore', 'shop' ].each do |location|
		describe "#in_#{location}" do
			it "should return true if :location is '#{location}'" do
				@location = location
				self.send("in_#{location}?").should == true
			end

			it "should return false if :location is not '#{location}'" do
				@location = ''
				self.send("in_#{location}?").should == false
			end
		end
	end

	describe "#customer_local_navi" do
		it "should render learn navigation if in_learn?" do
			self.stub!(:in_learn?).and_return(true)
			self.should_receive(:render).with(:partial => 'layouts/customer/learn_navi')
			customer_local_navi
		end

		it "should render explore navigation if in_explore?" do
			self.stub!(:in_learn?).and_return(false)
			self.stub!(:in_explore?).and_return(true)
			self.should_receive(:render).with(:partial => 'layouts/customer/explore_navi')
			customer_local_navi
		end
	end

	describe "#learn_link" do
		before(:each) do
      @attributes = { :id => 'learn_chevron', :class => 'learn chevron' }
		end

		describe "initial_visit" do
			it "should return a formatted link" do
        @attributes[:onmouseover] = "CustomerNavi.replaceNaviDetailsWith('');"
        @attributes[:onmouseout] = "CustomerNavi.replaceNaviDetailsWith('');"
				self.stub!(:initial_visit?).and_return(true)
				self.stub!(:render).and_return('')
				self.stub!(:details_for_current_customer_view).and_return('')
    	  learn_link.should == content_tag('li', link_to("#{content_tag('strong', 'Learn')} the basics", learn_url), @attributes)
			end
		end

		describe "returning visit" do
			describe "to non learn url" do
				it "should return a formatted link" do
    	    @attributes[:onmouseover] = "CustomerNavi.replaceNaviDetailsWith('');"
    	    @attributes[:onmouseout] = "CustomerNavi.replaceNaviDetailsWith('');"
					self.stub!(:initial_visit?).and_return(false)
					self.stub!(:in_learn?).and_return(false)
					self.stub!(:render).and_return('')
					self.stub!(:details_for_current_customer_view).and_return('')
    		  learn_link.should == content_tag('li', link_to("#{content_tag('strong', 'Learn')} the basics", learn_url), @attributes)
				end
			end

			describe "user visit to learn url" do
				it "should return a formatted link" do
					self.stub!(:initial_visit?).and_return(false)
					self.stub!(:in_learn?).and_return(true)
    		  learn_link.should == content_tag('li', link_to("#{content_tag('strong', 'Learn')} the basics", learn_url), @attributes)
				end
			end
		end
	end

	describe "#explore_link" do
		before(:each) do
      @attributes = { :id => 'explore_chevron', :class => 'explore chevron' }
		end

		describe "non explore url" do
			describe "user or user profile is blank?" do
				it "should return a formatted url" do
					self.stub!(:in_explore?).and_return(true)
      		explore_link.should == content_tag('li', link_to("#{content_tag('strong', 'Explore')} your options", '', { :class => 'inactive' }), @attributes)
				end
			end

			describe "user has profile that is blank or getting_started?" do
				it "should return a formatted url" do
					@profile = stub_model(Profile)
					@profile.stub!(:getting_started?).and_return(false)
					@user = stub_model(User)
					@user.stub!(:profile).and_return(@profile)

      		@attributes[:onmouseover] = "CustomerNavi.replaceNaviDetailsWith('');"
      		@attributes[:onmouseout] = "CustomerNavi.replaceNaviDetailsWith('');"
					self.stub!(:in_explore?).and_return(false)
					self.stub!(:render).and_return('')
					self.stub!(:details_for_current_customer_view).and_return('')

      		explore_link.should == content_tag('li', link_to("#{content_tag('strong', 'Explore')} your options", explore_url, {}), @attributes)
				end
			end
		end
	end

	describe "#shop_link" do
		before(:each) do
      @attributes = { :id => 'shop_chevron', :class => 'shop chevron' }
		end

		describe "non shop url" do
			describe "user or user profile is blank?" do
				it "should return a formatted url" do
					self.stub!(:in_shop?).and_return(true)
					shop_link.should == content_tag('li', link_to("#{content_tag('strong', 'Shop')} for a system", '', { :class => 'inactive' }), @attributes)
				end
			end

			describe "user has profile that is rfq" do
				it "should return a formatted url" do
					@profile = stub_model(Profile)
					@profile.stub!(:rfq?).and_return(true)
					@user = stub_model(User)
					@user.stub!(:profile).and_return(@profile)

      		@attributes[:onmouseover] = "CustomerNavi.replaceNaviDetailsWith('');"
      		@attributes[:onmouseout] = "CustomerNavi.replaceNaviDetailsWith('');"
					self.stub!(:in_shop?).and_return(false)
					self.stub!(:render).and_return('')
					self.stub!(:details_for_current_customer_view).and_return('')

					shop_link.should == content_tag('li', link_to("#{content_tag('strong', 'Shop')} for a system", '', { :class => 'inactive' }), @attributes)
				end
			end
		end
	end

	describe "#details_for_current_customer_view" do
		describe "initial visit" do
			it "should render customer welcome partial" do
				self.stub!(:initial_visit?).and_return(true)
				self.should_receive(:render).with(:partial => 'layouts/customer/welcome')
				details_for_current_customer_view
			end
		end

		describe "user visit" do
		 	before(:each) do
		 		self.stub!(:initial_visit?).and_return(false)
		 	end

		 	it "should render learn_details if in_learn?" do
				self.stub!(:in_learn?).and_return(true)
		 		self.should_receive(:render).with(:partial => 'layouts/customer/learn_details')
		 		details_for_current_customer_view
		 	end

		 	describe "if in_explore?" do
				before(:each) do
					self.stub!(:in_explore?).and_return(true)
				end

				describe "when user is blank" do
					it "should render explore_details using preset profile" do
						@profile = stub_model(Profile)
						@user = nil
		 				self.should_receive(:render).with(:partial => 'layouts/customer/explore_details', :locals => { :profile => @profile })
		 				details_for_current_customer_view
					end
				end

				describe "when user is not a customer" do
					it "should render explore_details using preset profile" do
						@profile = stub_model(Profile)
						@user = stub_model(User)
		 				self.should_receive(:render).with(:partial => 'layouts/customer/explore_details', :locals => { :profile => @profile })
		 				details_for_current_customer_view
					end
				end

				describe "when user is a customer" do
					it "should render explore_details using user profile" do
						@profile = stub_model(Profile)
						@user = stub_model(Customer)
						@user.stub!(:profile).and_return(@profile)
		 				self.should_receive(:render).with(:partial => 'layouts/customer/explore_details', :locals => { :profile => @profile })
		 				details_for_current_customer_view
					end
				end
		 	end

		 	it "should render shop_details if in_shop?" do
				self.stub!(:in_shop?).and_return(true)
		 		self.should_receive(:render).with(:partial => 'layouts/customer/shop_details')
		 		details_for_current_customer_view
		 	end
		end
	end

	describe "#submit_button" do
		it "should return a button with a submit type" do
			submit_button('Submit').should == content_tag('button', 'Submit', { :type => 'submit' })
		end
	end

	describe "#possible_filing_statuses" do
		it "should return an array of statuses" do
    	possible_filing_statuses.should == [ 'Single', 'Married', 'Married filing separately', 'Head of household' ]
		end
  end

	describe "#possible_lead_dispositions" do
		it "should return an array of dispositions" do
    	possible_lead_dispositions.should == [ 'Sold', 'Decided not to buy', 'Not ready to purchase at this time', 'Could not contact' ]
		end
  end

	describe "#states_by_abbreviation" do
		it "should return 51 states" do
			states_by_abbreviation.size.should == 51
		end
	end

	describe "#full_state_name_for" do
		it "should return a full state name for a given abbreviation" do
			self.should_receive(:states_by_abbreviation).and_return({ 'CA' => 'California' })
			full_state_name_for('CA').should == 'California'
		end
	end
end
