shared_examples_for "a controller that provides access to 'About'" do
  describe "#about on GET" do    
		before(:each) do
		  perform_additional_before_actions
			get 'about'
		end

    it "should respond :success" do
      response.should be_success
    end

    it "should set @view_title to 'About Renewzle: Solar Tool Connecting Homeowners & Installers'" do
      assigns[:view_title].should == 'About Renewzle: Solar Tool Connecting Homeowners & Installers'
    end
    
    it "should set @meta_description to 'Brought to you by Renewzle Inc., Renewzle is a green web tool designed to help consumers better understand the financial and environmental effects of solar energy and to help homeowners shop for a solar system that fits their needs. Renewzle is a solar calculator that helps you find the best installer in your area.'" do
      assigns[:meta_description].should == 'Brought to you by Renewzle Inc., Renewzle is a green web tool designed to help consumers better understand the financial and environmental effects of solar energy and to help homeowners shop for a solar system that fits their needs. Renewzle is a solar calculator that helps you find the best installer in your area.'
    end
    
    it "should set @meta_keywords to 'renewzle, what is renewzle, greenweb, renewzle solar power tool, green options solar tool, greenweb tool'" do
      assigns[:meta_keywords].should == 'renewzle, what is renewzle, greenweb, renewzle solar power tool, green options solar tool, greenweb tool'
    end
  end
  
  def perform_additional_before_actions
  end
end

shared_examples_for "a controller that provides access to 'Press'" do
  describe "#about on GET" do    
		before(:each) do
		  perform_additional_before_actions
			get 'press'
		end

    it "should respond :success" do
      response.should be_success
    end

    it "should set @view_title to 'Renewzle in the News'" do
      assigns[:view_title].should == 'Renewzle in the News'
    end
  end
  
  def perform_additional_before_actions
  end
end

shared_examples_for "a controller that provides access to 'FAQ'" do
  describe "#faq on GET" do    
		before(:each) do
		  perform_additional_before_actions
			get 'faq'
		end

    it "should respond :success" do
      response.should be_success
    end

    it "should set @view_title to 'Frequently Asked Questions about Renewzle & Installing a Solar System'" do
      assigns[:view_title].should == 'Frequently Asked Questions about Renewzle & Installing a Solar System'
    end
    
    it "should set @meta_description to 'Have questions about Renewzle and installing a solar power system? Find answers here. Information on solar system sizing, solar energy costs and financial analysis, proposals and quotes from installers, and how to work with Renewzle.'" do
      assigns[:meta_description].should == 'Have questions about Renewzle and installing a solar power system? Find answers here. Information on solar system sizing, solar energy costs and financial analysis, proposals and quotes from installers, and how to work with Renewzle.'
    end
    
    it "should set @meta_keywords to 'renewzle frequently asked questions, renewzle faq, solar power faq, solar system size, solar financial analysis, solar panel rfp'" do
      assigns[:meta_keywords].should == 'renewzle frequently asked questions, renewzle faq, solar power faq, solar system size, solar financial analysis, solar panel rfp'
    end
  end
  
  def perform_additional_before_actions
  end
end

shared_examples_for "a controller that provides access to 'Privacy Policy'" do
  describe "#privacy_policy on GET" do    
		before(:each) do
		  perform_additional_before_actions
			get 'privacy_policy'
		end

    it "should respond :success" do
      response.should be_success
    end

    it "should set @view_title to 'Privacy Policy'" do
      assigns[:view_title].should == 'Privacy Policy'
    end
  end
  
  def perform_additional_before_actions
  end
end

shared_examples_for "a controller that provides access to 'Terms of Service'" do
  describe "#tos on GET" do    
		before(:each) do
		  perform_additional_before_actions
			get 'tos'
		end

    it "should respond :success" do
      response.should be_success
    end

    it "should set @view_title to 'Terms of Service'" do
      assigns[:view_title].should == 'Terms of Service'
    end
  end
  
  def perform_additional_before_actions
  end
end

shared_examples_for "a controller that provides access to 'About,' 'Press,' 'FAQ,' 'Privacy Policy,' and 'Terms of Service'" do
  it_should_behave_like "a controller that provides access to 'About'"
  it_should_behave_like "a controller that provides access to 'Press'"
  it_should_behave_like "a controller that provides access to 'FAQ'"
  it_should_behave_like "a controller that provides access to 'Privacy Policy'"
  it_should_behave_like "a controller that provides access to 'Terms of Service'"
end