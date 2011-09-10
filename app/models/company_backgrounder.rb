class CompanyBackgrounder < ActiveRecord::Base
  acts_as_mappable
  
  belongs_to :company
  belongs_to :partner
  
  has_many :quotes
  
  upload_column :doc, :extensions => %w(txt pdf doc rtf), :tmp_dir => "/tmp", :store_dir => proc {|r,f| "system/backgrounders/" + f.attribute.to_s + "/" + r.company.id.to_s}
  
  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :company_id, :message => 'already exists'
  validates_length_of :title, :maximum => 255, :allow_nil => true
  
  validates_presence_of :doc, :on => :create
  validates_integrity_of :doc, :on => :create
  validates_each :doc, :on => :create do |record, attr, value|
    record.errors.add attr, 'already exists' if value and CompanyBackgrounder.find(:first, :conditions => ["#{attr.to_s} = ? AND company_id = ?", value.filename, record.company.id ] )
  end
  validates_each :doc, :on => :create do |record, attr, value|
    record.errors.add attr, 'is required' if value && value.filename.blank?
  end
  validates_size_of :doc, 
    :maximum  => 1024 * 1024 * 8, 
    :message  => "is too big, must be smaller than 8MB",
    :on       => :create,
    :if       => proc {|record| record.doc != nil and !record.doc.empty?}
  
  named_scope :last_waiting_approval, 
    :conditions => [ 'waiting_approval = ?', true ], 
    :order      => 'created_at DESC', 
    :limit      => 20
  
  named_scope :available,
    :conditions => [ 'waiting_approval = ? AND approved = ?', false, true ], 
    :order      => 'title' 
  
  after_create :notify_on_create
  
  def approve
    if self.waiting_approval?
      self.waiting_approval = false
      self.approved = true
      self.reviewed_at = Time.now
      self.save!
      CompanyBackgrounderNotifier.deliver_on_approve_notification(self)
    end
  end
  
  def reject(comments)
    if self.waiting_approval?
      self.waiting_approval = false
      self.approved = false
      self.reviewed_at = Time.now
      self.comments = comments
      self.save!
      CompanyBackgrounderNotifier.deliver_on_reject_notification(self)
    end
  end
  
private

  def notify_on_create
    #CompanyBackgrounderNotifier.deliver_on_create_notification(self)
  end
   
end
