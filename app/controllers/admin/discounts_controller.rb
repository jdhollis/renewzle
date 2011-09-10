class Admin::DiscountsController < AdminController
  ssl_required :index, :show, :new, :create, :edit, :update, :destroy
  
	def index
		@discounts = Discount.paginate(:per_page => 20, :page => params[:page])
	end	

	def show
		@discount = Discount.find(params[:id])
	end

	def new
	  @type = params[:type]
    @discount = new_discount(params)
    @discount.global = true
	end

	def create
    @discount = new_discount(params[:discount])
		@discount.save!
		flash[:notice] = 'Discount saved.'
		redirect_to(admin_discounts_url)
	rescue ActiveRecord::RecordInvalid
		render(:action => 'new')
	end

	def edit
		@discount = Discount.find(params[:id])
    @discount.global = @discount.global?
	end

	def update
		@discount = Discount.find(params[:id])
		@discount.attributes = params['discount']
    @discount.save!
		flash[:notice] = 'Discount updated.'
		redirect_to(admin_discounts_url)
	rescue ActiveRecord::RecordInvalid
		render(:action => 'edit')
	end

	def destroy
		@discount = Discount.find(params[:id])
		@discount.destroy
		flash[:notice] = 'Discount has been removed.'
		redirect_to(admin_discounts_url)
	end

private

  def new_discount(params = nil)
    unless params.nil?
      type = params.delete('type')
      if type && type.downcase == 'first_lead_discount'
        return FirstLeadDiscount.new(params)
      end
    end
    Discount.new(params)
  end
end
