class Customer < User
  acts_as_soft_deletable
  
  has_one :profile, :dependent => :destroy
  
  has_one :administrator, :as => :mask
  
  validates_presence_of :first_name
  validates_length_of :first_name, :maximum => 255

  validates_presence_of :last_name
  validates_length_of :last_name, :maximum => 255
  
  validates_presence_of :street_address
  validates_length_of :street_address, :maximum => 255
  
  validates_presence_of :city
  validates_length_of :city, :maximum => 255
  
  validates_presence_of :state
  validates_length_of :state, :is => 2
  
  validates_presence_of :postal_code
  validates_length_of :postal_code, :in => 5..10
  validates_format_of :postal_code, :with => /[0-9]{5}/, :if => Proc.new { |customer| !customer.postal_code.blank? && customer.postal_code.length <= 5 }, :message => 'must be at least 5 digits (e.g., <em>94044</em>)'
  validates_format_of :postal_code, :with => /[0-9]{5}-[0-9]{4}/, :if => Proc.new { |customer| !customer.postal_code.blank? && customer.postal_code.length > 5 }, :message => 'must be at least 5 digits (e.g., <em>94044</em>)'
  
  validates_presence_of :phone_number
  validates_length_of :phone_number, :maximum => 255

	#before_create :set_verification_code
  before_save :geocode

  def set_address_from(profile)
    unless profile.blank?
      self.street_address = profile.street_address
      self.city = profile.city
      self.state = profile.state
      self.postal_code = profile.postal_code
    end
  end
  
#  def verify!
#		self.verified_at = Time.now.utc
#		save!
#    CustomerNotifier.deliver_registration_confirmation_to(self)
#	end

	def verified?
		#!verified_at.blank?
		true
	end

	def verifying_email?
		!verified? && !verification_code.blank?
	end

  def address
    GeoKit::GeoLoc.new({ :street_address => street_address, :city => city, :state => state, :zip => postal_code })
  end

private
  
  def geocode
    geoloc = GeoKit::Geocoders::MultiGeocoder.geocode(address)
    if geoloc.success
      [ :lat, :lng ].each { |attribute| self.send("#{attribute}=", geoloc.send(attribute)) }
    end
  end

	#def set_verification_code
	#	self.verification_code = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)
	#end
end
