class Company < ActiveRecord::Base
  acts_as_mappable
  acts_as_soft_deletable
  
  has_many :partners, :dependent => :destroy, :after_add => Proc.new { |company, partner| company.claimed = true }, :after_remove => Proc.new { |company, partner| company.claimed = false unless company.has_partners? }
  has_many :discounts, :dependent => :destroy
  has_many :company_backgrounders, :dependent => :destroy
  has_and_belongs_to_many :geo_regions, :uniq => true

  has_many :leads, :through => :partners do
    def purchased
      find_all_by_purchased(true)
    end
  end
  
  has_many :quote_templates, :through => :partners

  named_scope :recently_claimed, :conditions => [ 'claimed = ?', true ], :order => 'updated_at DESC', :limit => 20
  named_scope :unclaimed_with_name_like, lambda { |name| { :conditions => [ 'claimed = ? AND LOWER(cec_name) LIKE ?', false, "%#{name}%" ] } }
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 255, :allow_nil => true

  validates_presence_of :street_address
  validates_length_of :street_address, :maximum => 255, :allow_nil => true
  
  validates_presence_of :city
  validates_length_of :city, :maximum => 255, :allow_nil => true
  
  validates_presence_of :state
  # validates_length_of :state, :maximum => 2, :allow_nil => true
  
  validates_presence_of :postal_code
  
  validates_presence_of :phone_number
  validates_length_of :phone_number, :maximum => 255, :allow_nil => true

  validates_presence_of :total_kw_installed, :if => Proc.new { |record| record.installs? }

  validates_presence_of :contractors_license_number, :if => Proc.new { |record| record.installs? }

  validates_presence_of :in_business_since

  #before_create :geocode
  
  attr_accessible :name, :email, :url, :street_address, :city, :state, :postal_code, :country, :phone_number, :fax_number, :installs, :raw_total_kw_installed, :contractors_license_number, :in_business_since

  def self.find_company_by_name(name)
    if company = Company.find_by_name(name)
      company
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def installs?
    installs
  end

  def address
    address = {}
    address[:street_address] = street_address.sub(/ ?(P ?\.? ?O\.?)? Box \d+/i, '').sub(/(PMB|Apt(\.)?|Unit|#|Suite|Ste(\.)?( )+) ?\w/i, '').gsub(/Attn: $/i, '')
    address[:city] = city
    address[:state] = state
    address[:zip] = (country == 'United States') ? postal_code : ''
    sprintf("%s %s, %s %s", address[:street_address], address[:city], address[:state], address[:zip])
  end

  def geocode
    self.geocodable = false
    self.city = nil
    self.state = nil

    geoloc = GeoKit::Geocoders::MultiGeocoder.geocode(address)
    if geoloc.success
      self.geocodable = true
      [ :lat, :lng, :city, :state ].each { |attribute| self.send("#{attribute}=", geoloc.send(attribute)) }
    end
  end

  def update_from(params)
    must_geocode = false
    if params.has_key?("postal_code")
      new_address = { :street_address => params["street_address"], :city => params.delete("city"), :state => params.delete("state"), :postal_code => params["postal_code"] }
      must_geocode = (address_has_changed?(new_address) || geocodable == false)
    end
    
    self.attributes = params
    geocode if must_geocode
    save!
  end

  def raw_total_kw_installed=(s)
    self.total_kw_installed = convert_string_to_positive_float(s)
  end

  def address_has_changed?(new_address)
    changed = false
    new_address.each { |attribute, new_value| changed = has_changed?(attribute, new_value) }
    changed
  end
  
  def has_changed?(attribute, new_value)
    !new_value.blank? && self.send(attribute) != new_value
  end
  
  def has_partners?
    !partners.blank?
  end
  
  def register(partner_params)
    partners.build(partner_params)
  end

  def lead_price_given(current_price, lead)
    price = current_price
    discounts.each { |discount| price = discount.apply_to(price, lead) }
    price
  end

  attr_accessor :cached_purchased_leads
  
  def purchased_leads
    if cached_purchased_leads.blank?
      self.cached_purchased_leads = leads.purchased
    end
    cached_purchased_leads
  end
  
  def has_purchased_leads?
    !purchased_leads.blank?
  end
  
  def default_to_cec_fields
    [ :name, :email, :url, :street_address, :city, :state, :postal_code, :country, :phone_number, :fax_number ].each do |attr|
      self.send("#{attr}=", self.send("cec_#{attr}"))
    end
  end
  
  def available_company_backgrounders
    company_backgrounders.available
  end

private

  def convert_string_to_positive_float(s)
    value = s.gsub(/[$,]/, '').to_f
    value > 0 ? value : nil
  end
end
