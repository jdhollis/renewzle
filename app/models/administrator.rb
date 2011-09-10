class Administrator < User
  belongs_to :mask, :polymorphic => true
  
  validates_presence_of :time_zone
  attr_accessible :time_zone
  
  def masquerade_as(user)
    self.mask = user
    save!
  end
  
  def stop_masquerading!
    self.mask = nil
    save!
  end
  
  def masquerading?
    !mask.blank?
  end
  
  def masquerading_as?(kind)
    !mask.blank? && mask.kind_of?(kind)
  end
  
  def profile
    masquerading_as?(Customer) ? mask.profile : nil
  end
end
