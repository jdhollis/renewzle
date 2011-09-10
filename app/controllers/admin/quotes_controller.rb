class Admin::QuotesController < AdminController
  ssl_required :index, :show, :destroy
  
	def index
    respond_to do |format|
      format.html do
		    @quotes = Quote.paginate(:per_page => 20, :page => params[:page])
      end
      format.rss do
        @quotes = Quote.recent
        render :layout => false
      end
    end
	end

	def show
		@quote = Quote.find(params[:id])
	end
	
	def destroy
		@quote = Quote.find(params[:id])
		@quote.destroy

		respond_to do |wants|
			wants.html do
				flash[:notice] = 'The quote has been withdrawn.'
				redirect_to(admin_quotes_url)
			end
			wants.js do 
				render(:update) do |page|
					page.visual_effect(:fade, dom_id(@quote))
					page.replace_html('messages', content_tag('p', 'The quote has been withdrawn.', :class => 'notice'))
					page.visual_effect(:highlight, 'messages')
				end
			end
		end
	end
end
