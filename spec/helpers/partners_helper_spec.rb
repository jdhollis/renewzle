require File.dirname(__FILE__) + '/../spec_helper'

describe PartnersHelper do
  include PartnersHelper

  describe "#company_search_results_for" do
    it "should render no_companies_found if companies is blank?"do
      @companies = []
      self.should_receive(:render).with(:partial => 'companies/no_companies_found')
      company_search_results_for(@companies)
    end

    it "should render company_search_results if companies is not blank?"do
      @companies = [ stub_model(Company) ]
      self.should_receive(:render).with(:partial => 'companies/company_search_results', :locals => { :companies => @companies, :search_term => '' })
      company_search_results_for(@companies)
    end
  end
  
  describe "#registration_for" do
    it "should render partial" do
      self.should_receive(:render).and_return('rendering')
      registration_for(mock_model(Partner), mock_model(Company)).should == 'rendering'
    end
  end

  describe "#purchased_leads_link" do
    it "should return markup" do
      self.stub!(:separator).and_return('')
      @partner = mock_model(Partner)
      @partner.should_receive(:has_purchased_leads?).and_return(true)
      purchased_leads_link.should == content_tag('li', link_to('My Leads', retailer_leads_url) + separator, :class => 'leads')
    end
  end

  describe "#edit_company_link" do
    it "should return markup" do
      self.stub!(:separator).and_return('')
      @company = mock_model(Company)
      @partner = mock_model(Partner)
      @partner.should_receive(:company).and_return(@company)
      @partner.should_receive(:can_update_company_profile?).and_return(true)
      edit_company_link.should == content_tag('li', link_to('My Company', edit_retailer_company_url(@company)) + separator, :class => 'company')
    end
  end
  
  describe "#manage_company_backgrounders_link" do
    it "should return markup" do
      self.stub!(:separator).and_return('')
      @partner = mock_model(Partner)
      @partner.should_receive(:can_manage_company_backgrounders?).and_return(true)
      manage_company_backgrounders_link.should == content_tag('li', link_to('Company Backgrounders', retailer_backgrounders_url) + separator, :class => 'backgrounders')
    end
  end

  describe "#administrator_title_for" do
    it "should return markup" do
      @user = mock_model(Partner)
      @user.should_receive(:company_administrator).and_return(true)
      administrator_title_for(@user).should == content_tag('span', 'Administrator', :class => 'title')
    end
  end

  describe "#make_quote_link_for" do
    it "should a link labelled 'Make a quote' when quotes are empty'" do
      @partner = mock_model(Partner)
      @partner.should_receive(:can_submit_quotes).and_return(true)
      @rfq = mock('rfq')
      make_quote_link_for(@rfq, mock(Array, :blank? => true)).should == link_to('Make a quote', retailer_new_quote_for_profile_url(@rfq), :class => "create")                                                       
    end

    it "should a link labelled 'Make another quote' when quotes are empty'" do
      @partner = mock_model(Partner)
      @partner.should_receive(:can_submit_quotes).and_return(true)
      @rfq = mock('rfq')
      make_quote_link_for(@rfq, mock(Array, :blank? => false)).should == link_to('Make another', retailer_new_quote_for_profile_url(@rfq), :class => "create")                                                       
    end
  end
end
