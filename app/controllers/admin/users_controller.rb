class Admin::UsersController < AdminController
  ssl_required :index, :show, :edit, :update, :destroy
  
	def index
    respond_to do |format|
      format.html do
		    @users = User.paginate(:order => 'email', :per_page => 20, :page => params[:page])
      end
      format.rss do
		    @users = User.recent
        render :layout => false
      end
    end
	end	

	def show
		@user = User.find(params[:id])
	end

	def edit
		@user = User.find(params[:id])
	end

	def update
    respond_to do |format|
      format.html do
		    @user = User.find(params[:id])
		    @user.update_from(params[:user])
		    flash[:notice] = "#{@user.email} updated."
		    redirect_to(admin_users_url)
      end
      format.js do
		    @partner = Partner.find(params[:id])
        (params[:partner][:waiting_approval] == 'approve') ? @partner.approve! : @partner.decline!
        render(:update) do |page|
          page.visual_effect(:fade, dom_id(@partner))
        end
      end
    end
	rescue ActiveRecord::RecordInvalid
		render(:action => 'edit')
	end

	def destroy
		@user = User.find(params[:id])
		@user.destroy
		flash[:notice] = "#{@user.email} has been removed."
		redirect_to(admin_users_url)
	end
end
