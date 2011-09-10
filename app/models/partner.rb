class Partner < User
  acts_as_soft_deletable
  
  belongs_to :company
	has_many :quotes, :dependent => :destroy
  has_many :quote_templates, :dependent => :destroy
  
	with_options :class_name => 'Lead', :order => 'closed, created_at', :dependent => :destroy do |parent|
		parent.has_many :leads
		parent.has_many :purchased_leads, :conditions => "purchased = 1"
		parent.has_many :unpurchased_leads, :conditions => "purchased = 0"
	end

  named_scope :waiting_approval, :conditions => { :waiting_approval => true }
  
  validates_presence_of :phone_number
  validates_length_of :phone_number, :maximum => 255
  
  before_create :become_administrator_if_no_other_partners

  delegate :total_kw_installed, :to => :company
  delegate :lead_price_given, :to => :company
  delegate :in_business_since, :to => :company
  
  attr_accessible :can_update_company_profile, :can_submit_quotes, :can_purchase_leads

	def rfqs
		Profile.find_rfqs
	end

	def quotes_by_rfq
		quotes.group_by(&:profile_id)
	end

	def has_purchased_leads?
		!purchased_leads.blank?
	end

  def approve!
    update_attribute(:waiting_approval, false)
  end

  def decline!
    self.destroy
  end
  
  def find_company_quote_template(quote_template_id)
    quote_templates.find(quote_template_id)
  rescue ActiveRecord::RecordNotFound
    company.quote_templates.find(quote_template_id)
  end
  
  delegate :available_company_backgrounders, :to => :company

private

  def become_administrator_if_no_other_partners
    if company.partners.count == 0
      self.company_administrator = true
      self.can_update_company_profile = true
      self.can_submit_quotes = true
      self.can_purchase_leads = true
      self.can_manage_company_backgrounders = true
      self.can_manage_counties = true
    end
  end
end
