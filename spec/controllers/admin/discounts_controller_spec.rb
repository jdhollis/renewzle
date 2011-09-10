require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared/login_stubs'
require File.dirname(__FILE__) + '/../shared/ssl'
require File.dirname(__FILE__) + '/shared/shared_admin_examples'

describe Admin::DiscountsController do
  include LoginStubs
  include SSL

	before(:each) do
	  require_ssl
    @discount_id = '1'
		@discount = mock_model(Discount)
	end 

  describe "#index on GET" do
    it_should_behave_like "an admin controller"
    
    describe "when user is an admin" do
      before(:each) do
        setup_valid_login_credentials_for(Administrator)
        
        @discounts = mock('discounts')
        Discount.should_receive(:paginate).with(:per_page => 20, :page => params[:page]).and_return(@discounts)
        
        do_action
      end
      
      it "should find all discounts and assign them to @discounts" do
  			assigns[:discounts].should be(@discounts)
  		end
    end
		
		def do_action
		  get 'index'
		end
		
		def setup_shared_stubs
	  end
  end
  
  describe "#show on GET" do
	  it_should_behave_like "an admin controller"
	  
	  describe "when user is an admin" do
      before(:each) do
       	setup_valid_login_credentials_for(Administrator)
       	setup_shared_stubs
  			do_action
  		end

  		it "should respond :success" do
  			response.should be_success
  		end

  		it "should find the discount to show and assign it to @discount" do
  			assigns[:discount].should be(@discount)
  		end
	  end
	  
	  def do_action
	    get 'show', { :id => @discount_id }
	  end
	end

	describe "#new on GET" do	  
	  it_should_behave_like "an admin controller"
	  
	  describe "when user is an admin" do
      before(:each) do
       	setup_valid_login_credentials_for(Administrator)
       	do_action
  		end

      describe "when discount is a normal discount" do
  		  it "should respond :success" do
  		  	response.should be_success
  		  end
      end

      describe "when discount is a first lead discount" do
        it "should respond :success" do
  		  	response.should be_success
  		  end

        it "should load a first lead discount" do
          assigns[:discount].class.should == FirstLeadDiscount
        end

        def do_action
          get 'new', { :type => 'first_lead_discount' }
        end
      end
	  end
		
		def do_action
		  get 'new'
		end
	end

	describe "#create on POST" do
	  it_should_behave_like "an admin controller"
	  
	  describe "when user is an admin" do
      before(:each) do
       	setup_valid_login_credentials_for(Administrator)
        setup_shared_stubs
        @discount_params = { 'id' => @discount_id, 'first_lead' => 0, 'global' => 0 }
  		end

  		describe "on a successful post" do
  			before(:each) do
					Discount.should_receive(:new).with(@discount_params).and_return(@discount)
  				@discount.should_receive(:save!)
  				do_action
  			end

        describe "when discount is a normal discount" do
  			  it "should set flash[:notice] to 'Discount saved.'" do
  			  	flash[:notice].should == 'Discount saved.'
  			  end

  			  it "should respond with a redirect" do
  			  	response.should be_redirect
  			  	response.should redirect_to(admin_discounts_url)
  			  end
        end
  		end

  		describe "when there are validation errors" do
  		  before(:each) do
					Discount.should_receive(:new).with(@discount_params).and_return(@discount)
  		    @discount.errors.stub!(:full_messages).and_return([])
          @discount.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(@discount))
  		  end
  		  
  			it "should render 'edit'" do
          controller.expect_render(:action => 'new')
  				do_action
  			end
  		end
	  end

	  def do_action
	    post 'create', { 'id' => @discount_id, 'discount' => @discount_params }
	  end
	end

	describe "#edit on GET" do	  
	  it_should_behave_like "an admin controller"
	  
	  describe "when user is an admin" do
      before(:each) do
       	setup_valid_login_credentials_for(Administrator)
        setup_shared_stubs
       	do_action
  		end

  		it "should respond :success" do
  			response.should be_success
  		end

  		it "should find the discount to edit and assign it to @discount" do
  			assigns[:discount].should be(@discount)
  		end
	  end
		
		def do_action
		  get 'edit', { :id => @discount_id }
		end
	end

	describe "#update on POST" do
	  it_should_behave_like "an admin controller"
	  
	  describe "when user is an admin" do
      before(:each) do
       	setup_valid_login_credentials_for(Administrator)
        setup_shared_stubs
        @discount_params = { 'id' => @discount_id, 'first_lead' => 0, 'global' => 0 }
  		end

  		describe "on a successful update" do
  			before(:each) do
  				do_action
  			end

  			it "should set flash[:notice] to 'Discount updated.'" do
  				flash[:notice].should == 'Discount updated.'
  			end

  			it "should respond with a redirect" do
  				response.should be_redirect
  				response.should redirect_to(admin_discounts_url)
  			end
  		end

  		describe "when there are validation errors" do
  		  before(:each) do
  		    @discount.errors.stub!(:full_messages).and_return([])
          @discount.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(@discount))
  		  end
  		  
  			it "should render 'edit'" do
          controller.expect_render(:action => 'edit')
  				do_action
  			end
  		end
	  end
	  
	  def do_action
	    post 'update', { :id => @discount_id, 'discount' => @discount_params }
	  end
	end

	describe "#destroy on GET" do
	  it_should_behave_like "an admin controller"
	  
	  describe "when user is an admin" do
	    before(:each) do
       	setup_valid_login_credentials_for(Administrator)
       	setup_shared_stubs
        do_action
  		end

  		it "should set flash[:notice] to 'Discount has been removed.'" do
  			flash[:notice].should == 'Discount has been removed.'
  		end

  		it "should respond with a redirect" do
  			response.should be_redirect
  			response.should redirect_to(admin_discounts_url)
  		end
	  end
		
		def do_action
		  delete 'destroy', { :id => @discount_id }
		end
		
		def setup_shared_stubs
		  stub_discount_find
		  @discount.should_receive(:destroy)
		end
	end
	
	def stub_discount_find
    Discount.stub!(:find).with(@discount_id).and_return(@discount)
  end
  
  def setup_shared_stubs
    @discount.stub!(:global=)
    @discount.stub!(:global?)
    @discount.stub!(:attributes=)
    @discount.stub!(:save!)
    stub_discount_find
  end
end
