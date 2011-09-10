class Retailer::PartnersController < RetailerController
  ssl_required :create, :edit, :update, :destroy

  def create
    @company = Company.find(params['company_id'])
    @new_partner = Partner.new(params['partner'])
    @new_partner.company = @company
    @new_partner.save!
    @new_partner.approve!

    render(:update) do |page|
      page.remove('new_partner_fields')
      page.insert_html(:bottom, 'partners', :partial => 'retailer/partners/partner', :locals => { :partner => @new_partner })
      page.insert_html(:bottom, 'partners', :partial => 'retailer/partners/new_partner', :locals => { :company => @company, :partner => @company.partners.build })
      page.visual_effect(:highlight, dom_id(@new_partner))
    end
  rescue ActiveRecord::RecordInvalid
    render(:update) do |page|
      page.replace_html('new_partner_fields', :partial => 'retailer/partners/new_partner_form', :locals => { :company => @company, :partner => @new_partner, :errors => true })
    end
  end

	def edit
		@location = 'account'
		@view_title = 'My Account'
    #@partner = @user
	end

	def update
    respond_to do |format|
      format.html do
		    #@partner = Partner.find(@user.id)
		    @partner.update_from(params[:partner])
		    flash[:notice] = 'Your account has been updated.'
		    redirect_to(retailer_dashboard_url)
      end

      format.js do
        params['partners'].each do |id, partner_params|
          @partner_to_update = Partner.find(id)
          @partner_to_update.update_from(partner_params)
          render(:update) do |page|
            page.replace_html(dom_id(@partner_to_update), :partial => 'retailer/partners/partner_form', :locals => { :partner => @partner_to_update })
            page.visual_effect(:highlight, dom_id(@partner_to_update))
          end
        end
      end
    end
	rescue ActiveRecord::RecordInvalid
    unless request.xhr?
		  render(:action => 'edit')
    else
      render(:update) do |page|
        page.replace_html(dom_id(@partner_to_update), :partial => 'retailer/partners/partner_form', :locals => { :partner => @partner_to_update, :errors => true })
      end
    end
	end

	def destroy
		#@partner = Partner.find(@user.id)
		@partner.destroy
		flash[:notice] = 'Your account has been deleted.'
		redirect_to(login_url)
	end
end
