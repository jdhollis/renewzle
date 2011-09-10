require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.dirname(__FILE__) + '/../shared/login_stubs'
require File.dirname(__FILE__) + '/../shared/ssl'
require File.dirname(__FILE__) + '/shared/shared_partner_examples'

describe Retailer::QuoteTemplatesController do
  include LoginStubs
  include SSL
  
  before(:each) do
    require_ssl
  end
  
  describe "#index on GET" do
    it_should_behave_like "a retailer controller"
    
    describe "when user is a partner" do
      before(:each) do
        setup_valid_login_credentials_for(Partner)
        @quote_templates = mock('quote templates')
        @user.should_receive(:quote_templates).and_return(@quote_templates)
      end

			it "should respond :success" do
				do_action
				response.should be_success
			end
			
			it "should set @location to 'quote_templates'" do
				do_action
				assigns[:location].should == 'quote_templates'
			end
			
			it "should set @view_title to 'Manage Quote Templates'" do
				do_action
				assigns[:view_title].should == 'Manage Quote Templates'
			end
			
			it "should set @quote_templates to the partner's existing quote templates" do
			  do_action
			  assigns[:quote_templates].should be(@quote_templates)
			end
    end
		
		def do_action
		  get 'index'
		end
  end
  
  describe "#new on GET" do
	  it_should_behave_like "a retailer controller"
	  
	  describe "when user is a partner" do
      before(:each) do
       	setup_valid_login_credentials_for(Partner)
       	@quote_template = mock_model(QuoteTemplate)
       	QuoteTemplate.should_receive(:new).and_return(@quote_template)
       	@user.should_receive(:available_company_backgrounders).and_return([])
  			do_action
  		end

  		it "should respond :success" do
  			response.should be_success
  		end

			it "should set @location to 'quote_templates'" do
				assigns[:location].should == 'quote_templates'
			end
			
			it "should set @view_title to 'Make a Quote Template'" do
				assigns[:view_title].should == 'Make a Quote Template'
			end

  		it "should create a QuoteTemplate and assign it to @quote_template" do
  			assigns[:quote_template].should be(@quote_template)
  		end
	  end
	  
	  def do_action
	    get 'new'
	  end
	end
	
	describe "#create on POST" do
	  it_should_behave_like "a retailer controller"
	  
	  describe "when user is a partner" do
	    before(:each) do
	      setup_valid_login_credentials_for(Partner)
	      @quote_template = mock_model(QuoteTemplate)
        @quote_template_params = { }
        QuoteTemplate.should_receive(:new).with(@quote_template_params.merge('partner' => @user)).and_return(@quote_template)
	    end
	    
			describe "and the request is normal" do
  			describe "on a successful create" do
  				before(:each) do
  					@quote_template.should_receive(:save!)
  					do_action
  				end

  				it "should set flash[:notice] to 'Quote template created.'" do
  					flash[:notice].should == 'Quote template created.'
  				end

  				it "should respond with a redirect to retailer_quote_templates_url" do
  					response.should be_redirect
  					response.should redirect_to(retailer_quote_templates_url)
  				end
  			end

  			describe "when there are validation errors" do
  			  before(:each) do
  			    @quote_template.errors.stub!(:full_messages).and_return([])
      	    @quote_template.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(@quote_template))
      	    @user.should_receive(:available_company_backgrounders).and_return([])
  			  end
  			  
  				it "should render 'new'" do
      	    controller.expect_render(:action => 'new')
  					do_action
  				end
  			end
			end

			describe "and the request is xhr?" do
    	  before(:each) do
    	    @quote_template_params.merge('photovoltaic_module_manufacturer' => 1, 'photovoltaic_inverter_manufacturer' => 1)
  			end

				it "should update #quote when updating quote" do
				  @quote_template.should_receive(:nameplate_rating)
				  @quote_template.should_receive(:cec_rating)
				  @quote_template.should_receive(:project_cost)
				  @quote_template.should_receive(:annual_output)
				  
					xhr :post, 'create', { 'update' => 'quote_template', 'quote_template' => @quote_template_params }
					response.should have_rjs(:replace_html, 'quote_template', :partial => 'retailer/quote_templates/quote_template', :locals => { :quote_template => @quote_template })
				end

				it "should update #modules when selecting a module manufacturer" do
				  @quote_template.stub!(:photovoltaic_module_id)
				  @quote_template.stub!(:number_of_modules)
					@modules = []
					PhotovoltaicModule.should_receive(:find_all_by_manufacturer).with(@quote_template_params['photovoltaic_module_manufacturer']).and_return(@modules)
					xhr :post, 'create', { 'update' => 'modules', 'quote_template' => @quote_template_params }
					response.should have_rjs(:replace_html, 'photovoltaic_module_fields', :partial => 'retailer/quote_templates/modules', :locals => { :quote_template => @quote_template, :modules => @modules })
				end

				it "should update #inverters when selecting a inverter manufacturer" do
				  @quote_template.stub!(:photovoltaic_inverter_id)
				  @quote_template.stub!(:number_of_inverters)
					@inverters = []
					PhotovoltaicInverter.should_receive(:find_all_by_manufacturer).with(@quote_template_params['photovoltaic_inverter_manufacturer']).and_return(@inverters)
					xhr :post, 'create', { 'update' => 'inverters', 'quote_template' => @quote_template_params }
					response.should have_rjs(:replace_html, 'photovoltaic_inverter_fields', :partial => 'retailer/quote_templates/inverters', :locals => { :quote_template => @quote_template, :inverters => @inverters })
				end
			end
	  end
	  
	  def do_action
	    post 'create', { 'quote_template' => @quote_template_params }
	  end
	end
	
	describe "#edit on GET" do
	  it_should_behave_like "a retailer controller"
	  
	  describe "when user is a partner" do
      before(:each) do
       	setup_valid_login_credentials_for(Partner)
       	@quote_templates = mock('quote templates')
       	@user.should_receive(:quote_templates).and_return(@quote_templates)
       	@quote_template_id = '1'
  		end
      
      describe "and the requested QuoteTemplate can't be found" do
        before(:each) do
          @quote_templates.should_receive(:find).with(@quote_template_id).and_raise(ActiveRecord::RecordNotFound)
        end
        
        it "should respond :missing" do
          do_action
          response.should be_missing
        end
        
        it "should render 404" do
          controller.expect_render(:file => 'public/404.html', :status => 404)
          do_action
        end
      end
      
      describe "and the requested QuoteTemplate can be found" do
        before(:each) do
          @description = 'Quote Template'
         	@quote_template = mock_model(QuoteTemplate)
         	@quote_template.should_receive(:description).and_return(@description)
          @quote_templates.should_receive(:find).with(@quote_template_id).and_return(@quote_template)
          @quote_template.should_receive(:set_manufacturers)
          @user.should_receive(:available_company_backgrounders).and_return([])
        end
        
        it "should respond :success" do
          do_action
    			response.should be_success
    		end

  			it "should set @location to 'quote_templates'" do
  			  do_action
  				assigns[:location].should == 'quote_templates'
  			end

  			it "should set @view_title to 'Edit #{@description}'" do
  			  do_action
  				assigns[:view_title].should == "Edit #{@description}"
  			end

    		it "should find the appropriate QuoteTemplate and assign it to @quote_template" do
    		  do_action
    			assigns[:quote_template].should be(@quote_template)
    		end
      end
	  end
	  
	  def do_action
	    get 'edit', { 'id' => @quote_template_id }
	  end
	end
	
	describe "#update on POST" do
	  it_should_behave_like "a retailer controller"
	  
	  describe "when user is a partner" do
	    before(:each) do
	      setup_valid_login_credentials_for(Partner)
	      
	      @quote_templates = mock('quote templates')
       	@user.should_receive(:quote_templates).and_return(@quote_templates)
	      
	      @quote_template = mock_model(QuoteTemplate)
	      @quote_template_id = '1'
	      
	      @quote_template_params = { }
	    end
	    
	    describe "and the requested QuoteTemplate can't be found" do
        before(:each) do
          @quote_templates.should_receive(:find).with(@quote_template_id).and_raise(ActiveRecord::RecordNotFound)
        end
        
        it "should respond :missing" do
          do_action
          response.should be_missing
        end
        
        it "should render 404" do
          controller.expect_render(:file => 'public/404.html', :status => 404)
          do_action
        end
      end
      
      describe "the requested QuoteTemplate can be found" do
		    before(:each) do
		      @quote_templates.should_receive(:find).with(@quote_template_id).and_return(@quote_template)
		      @quote_template.should_receive(:attributes=).with(@quote_template_params)
		    end
	    
			  describe "and the request is normal" do
  			  describe "on a successful update" do
    				before(:each) do
    					@quote_template.should_receive(:save!)
    					do_action
    				end

    				it "should set flash[:notice] to 'Quote template updated.'" do
    					flash[:notice].should == 'Quote template updated.'
    				end

    				it "should respond with a redirect to retailer_quote_templates_url" do
    					response.should be_redirect
    					response.should redirect_to(retailer_quote_templates_url)
    				end
    			end

    			describe "when there are validation errors" do
    			  before(:each) do
    			    @quote_template.errors.stub!(:full_messages).and_return([])
        	    @quote_template.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(@quote_template))
        	    @user.should_receive(:available_company_backgrounders).and_return([])
    			  end

    				it "should render 'edit'" do
        	    controller.expect_render(:action => 'edit')
    					do_action
    				end
    			end
  			end
			
			  describe "and the request is xhr?" do
      	  before(:each) do
      	    @quote_template_params.merge('photovoltaic_module_manufacturer' => 1, 'photovoltaic_inverter_manufacturer' => 1)
    			end

  				it "should update #quote when updating quote" do
  				  @quote_template.should_receive(:nameplate_rating)
  				  @quote_template.should_receive(:cec_rating)
  				  @quote_template.should_receive(:project_cost)
  				  @quote_template.should_receive(:annual_output)

  					xhr :post, 'update', { 'id' => @quote_template_id, 'update' => 'quote_template', 'quote_template' => @quote_template_params }
  					response.should have_rjs(:replace_html, 'quote_template', :partial => 'retailer/quote_templates/quote_template', :locals => { :quote_template => @quote_template })
  				end

  				it "should update #modules when selecting a module manufacturer" do
  				  @quote_template.stub!(:photovoltaic_module_id)
  				  @quote_template.stub!(:number_of_modules)
  					@modules = []
  					PhotovoltaicModule.should_receive(:find_all_by_manufacturer).with(@quote_template_params['photovoltaic_module_manufacturer']).and_return(@modules)
  					xhr :post, 'update', { 'id' => @quote_template_id, 'update' => 'modules', 'quote_template' => @quote_template_params }
  					response.should have_rjs(:replace_html, 'photovoltaic_module_fields', :partial => 'retailer/quote_templates/modules', :locals => { :quote_template => @quote_template, :modules => @modules })
  				end

  				it "should update #inverters when selecting a inverter manufacturer" do
  				  @quote_template.stub!(:photovoltaic_inverter_id)
  				  @quote_template.stub!(:number_of_inverters)
  					@inverters = []
  					PhotovoltaicInverter.should_receive(:find_all_by_manufacturer).with(@quote_template_params['photovoltaic_inverter_manufacturer']).and_return(@inverters)
  					xhr :post, 'update', { 'id' => @quote_template_id, 'update' => 'inverters', 'quote_template' => @quote_template_params }
  					response.should have_rjs(:replace_html, 'photovoltaic_inverter_fields', :partial => 'retailer/quote_templates/inverters', :locals => { :quote_template => @quote_template, :inverters => @inverters })
  				end
  			end
  	  end
		end
	  
	  def do_action
	    post 'update', { 'id' => @quote_template_id, 'quote_template' => @quote_template_params }
	  end
	end
	
	describe "#destroy on GET" do
    it_should_behave_like "a retailer controller"

		describe "when user is partner" do
      before(:each) do
        setup_valid_login_credentials_for(Partner)
        
        @quote_templates = mock('quote templates')
       	@user.should_receive(:quote_templates).and_return(@quote_templates)
	      
	      @quote_template = mock_model(QuoteTemplate)
	      @quote_template_id = '1'
      end
      
      describe "and the requested QuoteTemplate can't be found" do
        before(:each) do
          @quote_templates.should_receive(:find).with(@quote_template_id).and_raise(ActiveRecord::RecordNotFound)
        end
        
        it "should respond :missing" do
          do_action
          response.should be_missing
        end
        
        it "should render 404" do
          controller.expect_render(:file => 'public/404.html', :status => 404)
          do_action
        end
      end
      
      describe "the requested QuoteTemplate can be found" do
		    before(:each) do
		      @quote_templates.should_receive(:find).with(@quote_template_id).and_return(@quote_template)
		      @quote_template.should_receive(:destroy)
		    end
      
			  describe "and the request is normal" do
      	  before(:each) do
  					do_action
      	  end

  				it "should set flash[:notice] to 'Your quote template has been destroyed.'" do
  					flash[:notice].should == 'Your quote template has been destroyed.'
  				end

  				it "should respond with a redirect to retailer_quote_templates_url" do
  					response.should be_redirect
  					response.should redirect_to(retailer_quote_templates_url)
  				end
  			end

      	describe "and the request is xhr" do
      	  include ActionView::Helpers::TagHelper
      	  
      	  before(:each) do
  					do_xhr_action
      	  end

  				it "should respond :success" do
  					response.should be_success
  				end

  				it "should update #messages" do
  					response.should have_rjs(:replace_html, 'messages', content_tag('p', 'Your quote template has been destroyed.', :class => 'notice'))
  				end

  				def do_xhr_action
  					xhr :delete, 'destroy', { :id => @quote_template_id  }
  				end
      	end
  		end
    end
    
		def do_action
		  get 'destroy', { :id => @quote_template_id }
		end
	end
end
