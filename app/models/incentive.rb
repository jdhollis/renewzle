class Incentive < ActiveRecord::Base
  include Renewzle::UpdateFrom

  belongs_to :utility

  named_scope :federal_incentives, :conditions => { :city => nil, :state => nil, :utility_id => nil }
  named_scope :state_incentives_for, lambda { |state| { :conditions => { :city => nil, :state => state, :utility_id => nil } } }
  named_scope :city_incentives_for, lambda { |city, state| { :conditions => { :city => city, :state => state, :utility_id => nil } } }

	attr_accessible :city, :state, :source, :description, :notes, :utility_id, :derate, :rate, :minimum_system_size, :maximum_system_size, :maximum_amount, :maximum_percentage

  def applicable_to(profile_or_quote)
    if minimum_system_size.blank?
      applicable = true
    else
      applicable = profile_or_quote.nameplate_rating >= minimum_system_size
    end

    if maximum_system_size.blank?
      applicable = applicable && true
    else
      applicable = profile_or_quote.nameplate_rating <= maximum_system_size
    end

    applicable
  end
end
