class Admin::MasqueradesController < AdminController
  ssl_required :index, :create, :destroy
  
  def index
    setup_masquerade_assigns
  end
  
  def create
    mask_id = params['profile_id'] || params['customer_id'] || params['partner_id']
    mask_class = params['profile_id'].blank? ? User : Profile
    
    begin
      @mask = mask_class.find(mask_id)
      @user.masquerade_as(@mask)
      if @mask.kind_of?(Profile)
        remember(@mask)
        @profile = @mask
      end
      redirect_to(default_url)
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "Could not find #{mask_class.to_s.downcase} id #{mask_id} to masquerade as. Params: #{params.inspect}"
      redirect_to(default_url)
    end
  end
  
  def destroy
    cookies.delete('remembered_profile_id') if @user.masquerading_as?(Profile)
    @user.stop_masquerading!
    
    flash[:notice] = 'Stopped masquerading.'
    redirect_to(masquerade_panel_url)
  end
end