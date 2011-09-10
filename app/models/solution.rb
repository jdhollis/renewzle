class Solution < ActiveRecord::Base
  acts_as_soft_deletable
  
  belongs_to :lead
  belongs_to :profile
  belongs_to :partner
  belongs_to :quote
  belongs_to :photovoltaic_module
  belongs_to :photovoltaic_inverter

  validates_presence_of :profile_id
  validates_presence_of :partner_id
  validates_presence_of :quote_id
  validates_presence_of :lead_id
  validates_presence_of :photovoltaic_module_id
  validates_presence_of :number_of_modules
  validates_presence_of :photovoltaic_inverter_id
  validates_presence_of :number_of_inverters
  validates_presence_of :system_price
  validates_presence_of :disposition

  attr_accessor :photovoltaic_module_manufacturer
  attr_accessor :photovoltaic_inverter_manufacturer

  attr_accessible :profile, :lead, :quote, :partner, :quote_id, :partner_id, :lead_id, :profile_id, :disposition, :photovoltaic_module_id, :number_of_modules, :photovoltaic_inverter_id, :number_of_inverters, :system_price, :installation_estimate, :comments
  attr_accessible :raw_installation_estimate, :photovoltaic_module_manufacturer, :system_price
end
