class LeadsController < CustomerController
  before_filter :verify_user_is_customer

  ssl_required :new, :create
  
  def new
    @location = 'shop'
    @view_title = 'Accept quote?'
    @quote = Quote.find(params['id'])
    @partner = @quote.partner
    @profile = @quote.profile
    @lead = Lead.new(:quote => @quote, :partner => @partner, :profile => @profile)
  rescue ActiveRecord::RecordNotFound
    render(:file => 'public/404.html', :status => 404)
  end
  
  def create
    @profile = Profile.find(params['profile']['id'])
    @lead = Lead.new(params['lead'])
    @lead.profile = @profile
    @lead.save!
    flash[:notice] = 'Quote accepted. Expect to be contacted by the partner shortly.'
    redirect_to(shop_url)
  rescue ActiveRecord::RecordNotFound
    render(:file => 'public/404.html', :status => 404)
  end
end
