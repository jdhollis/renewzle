class CompaniesController < ApplicationController
  ssl_required :show

  def show
    @companies = Company.paginate(:all, :conditions => [ 'claimed = ? AND LOWER(cec_name) LIKE ?', false, "%#{params['search_term']}%" ], :order => 'cec_name ASC', :page => params[:page], :per_page => 20)
		respond_to do |format|
			format.html
			format.js do
				render(:update) do |page|
					page.replace_html('companies', :partial => 'company_search_results', :locals => { :companies => @companies, :search_term => params['search_term'] })
					page.delay(0.35) do
						page.visual_effect(:scroll_to, 'companies')
					end
				end
			end
		end
  end
end
