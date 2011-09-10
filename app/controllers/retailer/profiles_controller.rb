class Retailer::ProfilesController < RetailerController
	before_filter :verify_partner_is_approved, :except => [ :index ]

  def index
    @location = 'dashboard'
    @view_title = 'Dashboard'
    if @partner.company.geo_regions.empty?
      @service_area_details = "California"
    else
      region_names = []
      @partner.company.geo_regions[0..4].each { |region| region_names << region.region_name }
      @service_area_details = "#{region_names.sort { |a, b| a <=> b }.to_sentence} #{region_names.size > 1 ? 'counties' : 'county'}"
      @service_area_details = "#{@service_area_details} and others" if @partner.company.geo_regions.length > 5
    end
  end
end
