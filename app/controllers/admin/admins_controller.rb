class Admin::AdminsController < AdminController
  ssl_required :index
  
  def index
    @partners_waiting_approval = Partner.waiting_approval
    @profiles_waiting_approval = Profile.waiting_approval
    @backgrounders_waiting_approval = CompanyBackgrounder.last_waiting_approval
  end
end
