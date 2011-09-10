class Discount < ActiveRecord::Base
  include Renewzle::UpdateFrom

	belongs_to :company

  named_scope :global, :conditions => { :company_id => nil }

  validates_numericality_of :percentage, :allow_nil => true
  validates_numericality_of :price, :allow_nil => true

  attr_accessor :global

	attr_accessible :global, :company_id, :price, :percentage

  before_save :drop_company_id_if_global

  def global?
    company_id.blank?
  end

  def apply_to(current_price, lead)
    percentage.blank? ? price : current_price * percentage
  end

private

  def drop_company_id_if_global
    self.company_id = nil if global == true || global.to_i == 1
  end
end
