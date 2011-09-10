require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CompanyBackgrounder do
  before(:each) do
    @company_backgrounder = CompanyBackgrounder.new
    ["test.txt", "test.exe", "test.pdf", "test.doc", "test.rtf"].each do |filename|
      File.atomic_write("/tmp/" + filename) do |file|
        file.write("hello!")
      end
    end
    File.atomic_write("/tmp/test-9mb.txt") do |file|
      file.write("hello!!!!" * 1024 * 1024)
    end
  end

  it "should belong to a company" do
    @company_backgrounder.should respond_to(:company)
  end
  
  it "should belong to a partner" do
    @company_backgrounder.should respond_to(:partner)
  end
  
  it "should belong to a quote" do
    @company_backgrounder.should respond_to(:quotes)
  end
  
  it "should require title" do
    @company_backgrounder.company = mock_model(Company, :name => "Company")
    @company_backgrounder.should have(1).error_on(:title)
    @company_backgrounder.title = "Company Backgrounder"
    @company_backgrounder.should have(:no).errors_on(:title)
  end
  
  it "should require a title that is less than or equal to 255 characters in length" do
    long_title = ''
    0.upto(256) { |i| long_title << i.to_s  }
    @company_backgrounder.company = mock_model(Company, :name => "Company")
    @company_backgrounder.title = long_title
    @company_backgrounder.should have(1).error_on(:title)
    @company_backgrounder.errors.on(:title).should == 'is too long (maximum is 255 characters)'
  end
  
  it "should require a unique title within a company" do
    company = mock_model(Company, :name => "Company")
    tmp = CompanyBackgrounder.new(
      :title => 'Company Backgrounder', 
      :company => company, 
      :partner => mock_model(Partner, :email => "blabla@blabla.com")
    )
    tmp.save(false)
    @company_backgrounder.title = 'Company Backgrounder'
    @company_backgrounder.company = company
    @company_backgrounder.should have(1).error_on(:title)
    @company_backgrounder.errors.on(:title).should == 'already exists'
    tmp.destroy
  end
  
  it "should allow title to be changed via mass-assignment" do
    @company_backgrounder.company = mock_model(Company, :name => "Company")
    @company_backgrounder.title.should be_blank
    @company_backgrounder.attributes = { :title => 'Company Backgrounder' }
    @company_backgrounder.title.should == 'Company Backgrounder'
  end
  
  it "should require doc" do
    @company_backgrounder.company = mock_model(Company, :name => "Company")
    @company_backgrounder.should have(1).error_on(:doc)
    @company_backgrounder.doc = UploadColumn::SanitizedFile.new("/tmp/test.txt")
    @company_backgrounder.should have(:no).errors_on(:doc)
  end
  
  it "should require a unique doc within a company" do
    company = mock_model(Company, :name => "Company")
    tmp = CompanyBackgrounder.new(
      :doc => UploadColumn::SanitizedFile.new("/tmp/test.txt"),
      :company => company, 
      :partner => mock_model(Partner, :email => "test@test.com")
    )
    tmp.save(false)
    @company_backgrounder.doc = UploadColumn::SanitizedFile.new("/tmp/test.txt")
    @company_backgrounder.company = company
    @company_backgrounder.should have(1).error_on(:doc)
    @company_backgrounder.errors.on(:doc).should == 'already exists'
    tmp.destroy
  end
  
  it "should require doc only with .txt, .doc, .rtf and .pdf extensions" do
    @company_backgrounder.company = mock_model(Company, :name => "Company")
    @company_backgrounder.doc = UploadColumn::SanitizedFile.new("/tmp/test.exe")
    @company_backgrounder.should have(2).errors_on(:doc)
    @company_backgrounder.errors.on(:doc).should include('has an extension that is not allowed.')
    @company_backgrounder.doc = UploadColumn::SanitizedFile.new("/tmp/test.txt")
    @company_backgrounder.should have(:no).errors_on(:doc)
    @company_backgrounder.doc = UploadColumn::SanitizedFile.new("/tmp/test.pdf")
    @company_backgrounder.should have(:no).errors_on(:doc)
    @company_backgrounder.doc = UploadColumn::SanitizedFile.new("/tmp/test.doc")
    @company_backgrounder.should have(:no).errors_on(:doc)
    @company_backgrounder.doc = UploadColumn::SanitizedFile.new("/tmp/test.rtf")
    @company_backgrounder.should have(:no).errors_on(:doc)
  end
  
  it "should require doc with a size that less than 8Mb" do
    @company_backgrounder.company = mock_model(Company, :name => "Company")
    @company_backgrounder.doc = UploadColumn::SanitizedFile.new("/tmp/test-9mb.txt")
    @company_backgrounder.should have(1).error_on(:doc)
    @company_backgrounder.errors.on(:doc).should == 'is too big, must be smaller than 8MB'
  end
  
  it "should notify admin on creating" do
    @company_backgrounder.company = mock_model(Company, :name => "test")
    @company_backgrounder.partner = mock_model(Partner, :email => "test@test.com")
    @company_backgrounder.title = "test"
    @company_backgrounder.doc = UploadColumn::SanitizedFile.new("/tmp/test.txt")
    @company_backgrounder.save(false)
  end
  
  describe "#approve" do
    before(:each) do
      @company_backgrounder.company = mock_model(Company, :name => "test")
      @company_backgrounder.partner = mock_model(Partner, :email => "test@test.com")
      @company_backgrounder.title = "test"
      @company_backgrounder.doc = UploadColumn::SanitizedFile.new("/tmp/test.txt")
      @company_backgrounder.should_receive(:waiting_approval?).and_return(true)
      @company_backgrounder.should_receive(:save!)
    end

    it "should set :approved to true" do
      @company_backgrounder.should_receive(:approved=).with(true)
      @company_backgrounder.approve
    end
    
    it "should set :waiting_approval to false" do
      @company_backgrounder.should_receive(:waiting_approval=).with(false)
      @company_backgrounder.approve
    end
    
    it "should deliver a notification to owner" do
      CompanyBackgrounderNotifier.should_receive(:deliver_on_approve_notification).with(@company_backgrounder)
      @company_backgrounder.approve
    end
  end
    
  describe "#reject" do
    before(:each) do
      @company_backgrounder.company = mock_model(Company, :name => "test")
      @company_backgrounder.partner = mock_model(Partner, :email => "test@test.com")
      @company_backgrounder.title = "test"
      @company_backgrounder.doc = UploadColumn::SanitizedFile.new("/tmp/test.txt")
      @company_backgrounder.should_receive(:waiting_approval?).and_return(true)
      @company_backgrounder.should_receive(:save!)
    end
    
    it "should set :approved to false" do
      @company_backgrounder.should_receive(:approved=).with(false)
      @company_backgrounder.reject("test")
    end
    
    it "should set :waiting_approval to false" do
      @company_backgrounder.should_receive(:waiting_approval=).with(false)
      @company_backgrounder.reject("test")
    end
    
    it "should deliver a notification to owner" do
      CompanyBackgrounderNotifier.should_receive(:deliver_on_reject_notification).with(@company_backgrounder)
      @company_backgrounder.reject("test")
    end
  end
    
end
