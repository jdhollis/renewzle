require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared/login_stubs'
require File.dirname(__FILE__) + '/../shared/ssl'
require File.dirname(__FILE__) + '/shared/shared_admin_examples'

describe Admin::QuotesController do
  include LoginStubs
  include SSL

	before(:each) do
	  require_ssl
		@quote = mock_model(Quote)
	end 

  describe "#index on GET" do
    it_should_behave_like "an admin controller"
    
    describe "when user is an admin" do
      before(:each) do
        setup_valid_login_credentials_for(Administrator)
        
        @quotes = mock('quotes')
        Quote.should_receive(:paginate).with(:per_page => 20, :page => params[:page]).and_return(@quotes)
        
        do_action
      end
      
      it "should find all quotes and assign them to @quotes" do
  			assigns[:quotes].should be(@quotes)
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

  		it "should find the quote to show and assign it to @quote" do
  			assigns[:quote].should be(@quote)
  		end
	  end
	  
	  def do_action
	    get 'show', { :id => @quote_id }
	  end
	end
	
	def stub_quote_find
    @quote_id = '1'
    Quote.should_receive(:find).with(@quote_id).and_return(@quote)
  end
  
  def setup_shared_stubs
    stub_quote_find
  end
end
