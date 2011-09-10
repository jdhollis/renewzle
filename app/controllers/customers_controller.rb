class CustomersController < CustomerController
	before_filter :verify_user_is_customer, :only => [ :edit, :update, :destroy ]
  before_filter :recall_remembered_profile_if_any #, :except => :verify
  before_filter :redirect_to_new_profile_url_if_no_remembered_profile #, :except => :verify

  ssl_required :edit, :update
  
  def create
    @customer = Customer.new(params['customer'])
    @customer.profile = @profile
    @customer.save!
    
    cookies.delete('remembered_profile_id')
    
    unless !@user.blank? && @user.kind_of?(Administrator)
      login(@customer)
    else
      @user.masquerade_as(@customer)
    end
    
    @customer.profile.request_quotes!
    
    #flash[:notice] = 'Signup successful. A verification link was sent to your email address. Please follow that link to complete your request for quotes.'
    flash[:just_submitted_rfq] = true
    #redirect_to(session[:current_tab_url] || explore_url)
    redirect_to(rfq_confirmation_url)
  rescue ActiveRecord::RecordInvalid
    setup_request_quotes_assigns
    flash[:warning] = 'Please review and correct the validation errors below before resubmitting.'
    render(:template => 'content/request_quotes')
  end

  def edit
    @customer = @user.masquerading_as?(Customer) ? @user.mask : @user
    @view_title = 'My Account'
    @location = 'my_account'
  end

  def update
    @request_quotes = params['request_quotes']
    @customer = @user.masquerading_as?(Customer) ? @user.mask : @user
    @customer.update_from(params['customer'])
    
    if @request_quotes.blank?
      flash[:notice] = 'Your account has been updated.'
  		redirect_to(edit_customer_url)
		else
      @customer.profile.request_quotes!
      flash[:notice] = 'Your request for quotes has been submitted.'
      redirect_to(shop_url)
	  end
  rescue ActiveRecord::RecordInvalid
    if @request_quotes.blank?
      @view_title = 'My Account'
      @location = 'my_account'
      render(:action => 'edit')
    else
      setup_request_quotes_assigns
      flash[:warning] = 'Please review and correct the validation errors below before resubmitting.'
      render(:template => 'content/request_quotes')
    end
  end
  
#  def verify
#    if @user = Customer.find_by_verification_code(params[:verification_code])
#      @user.verify!
#      @user.profile.request_quotes!
#      flash[:notice] = 'Thanks for verifying your email address. Your request for quotes has been submitted.'
#      login(@user)
#      redirect_to(shop_url)
#    else
#      flash[:warning] = 'Invalid verification code. If you need help logging in or verifying your email address, please contact us at <a href="mailto:support@renewzle.com">support@renewzle.com</a>.'
#      redirect_to(learn_url)
#    end
#  end

  def destroy
    user = @user.masquerading_as?(Customer) ? @user.mask : @user
    user.destroy
    flash[:notice] = 'Your account has been cancelled.'
    redirect_to(explore_url)
  end
end
