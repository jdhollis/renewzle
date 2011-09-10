class Retailer::CountiesController < RetailerController
  before_filter :verify_partner_permissions
  
  def index
    if request.xhr?
      render(:update) do |page|
        case params[:update]
        when "counties"
          begin
            state = GeoState.find(params[:counties][:state_id])
#            self.setup_regions(params[:counties][:state_id])
            company_counties_ids = []
            @partner.company.geo_regions.find_all_by_geo_state_id(state.id).each { |county| company_counties_ids << county.id  }
            if company_counties_ids.length > 0
              @disabled_counties = state.geo_regions.find(:all, :order => 'region_name', :conditions => ["NOT(id IN (?))", company_counties_ids])
              @enabled_counties = state.geo_regions.find(:all, :order => 'region_name', :conditions => ["id IN (?)", company_counties_ids])
            else
              @disabled_counties = state.geo_regions.find(:all, :order => 'region_name')
              @enabled_counties = []
            end

            page.hide("counties_state_id_loading")
            page.replace_html(
              'manage_counties', 
              :partial  => 'retailer/counties/counties', 
              :locals   => { :disabled_counties => @disabled_counties, :enabled_counties => @enabled_counties }
            )
          rescue ActiveRecord::RecordNotFound
            page.hide("counties_state_id_loading")
            page.replace_html(
              'manage_counties'
            )
          end
        when "enable"
          region = GeoRegion.find(params[:region_id])

          @partner.company.geo_regions << region
          
#          setup_regions(region.geo_state_id)
          
          state = GeoState.find(region.geo_state_id)
          company_counties_ids = []
          @partner.company.geo_regions.each { |county| company_counties_ids << county.id  }
          if company_counties_ids.length > 0
            @disabled_counties = state.geo_regions.find(:all, :order => 'region_name', :conditions => ["NOT(id IN (?))", company_counties_ids])
            @enabled_counties = state.geo_regions.find(:all, :order => 'region_name', :conditions => ["id IN (?)", company_counties_ids])
          else
            @disabled_counties = state.geo_regions.find(:all, :order => 'region_name')
            @enabled_counties = []
          end
          
          #page.hide("counties_enable_loading")
          page.replace_html(
            'manage_counties', 
            :partial  => 'retailer/counties/counties', 
            :locals   => { :disabled_counties => @disabled_counties, :enabled_counties => @enabled_counties }
          )
        when "disable"
          region = GeoRegion.find(params[:region_id])

          @partner.company.geo_regions.delete(region)
          
#          setup_regions(region.geo_state_id)
          
          state = GeoState.find(region.geo_state_id)
          company_counties_ids = []
          @partner.company.geo_regions.each { |county| company_counties_ids << county.id  }
          if company_counties_ids.length > 0
            @disabled_counties = state.geo_regions.find(:all, :order => 'region_name', :conditions => ["NOT(id IN (?))", company_counties_ids])
            @enabled_counties = state.geo_regions.find(:all, :order => 'region_name', :conditions => ["id IN (?)", company_counties_ids])
          else
            @disabled_counties = state.geo_regions.find(:all, :order => 'region_name')
            @enabled_counties = []
          end
          
          #page.hide("counties_enable_loading")
          page.replace_html(
            'manage_counties', 
            :partial  => 'retailer/counties/counties', 
            :locals   => { :disabled_counties => @disabled_counties, :enabled_counties => @enabled_counties }
          )
        end
      end
    end
    @states = GeoState.find(:all, :order => 'state_code')
    @location = "counties"
    state = GeoState.find_by_state_code('CA')
    company_counties_ids = []
    @partner.company.geo_regions.find_all_by_geo_state_id(state.id).each { |county| company_counties_ids << county.id  }
    if company_counties_ids.length > 0
      @disabled_counties = state.geo_regions.find(:all, :order => 'region_name', :conditions => ["NOT(id IN (?))", company_counties_ids])
      @enabled_counties = state.geo_regions.find(:all, :order => 'region_name', :conditions => ["id IN (?)", company_counties_ids])
    else
      @disabled_counties = state.geo_regions.find(:all, :order => 'region_name')
      @enabled_counties = []
    end
  end
  
private
  
  def setup_regions(state_id)
    state = GeoState.find(state_id)
    company_counties_ids = []
    @partner.company.geo_regions.each { |county| company_counties_ids << county.id  }
    if company_counties_ids.length > 0
      @disabled_counties = state.geo_regions.find(:all, :order => 'region_name', :conditions => ["NOT(id IN (?))", company_counties_ids])
      @enabled_counties = state.geo_regions.find(:all, :order => 'region_name', :conditions => ["id IN (?)", company_counties_ids])
    else
      @disabled_counties = state.geo_regions.find(:all, :order => 'region_name')
      @enabled_counties = []
    end
  end
  
  def verify_partner_permissions
    unless @partner.can_manage_counties
      flash[:notice] = 'You do not have the permissions to perform that action.'
      redirect_to(retailer_dashboard_url)
    end
  end
  
end
