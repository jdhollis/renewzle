class Retailer::ContentController < RetailerController
  def about
    @view_title = 'About Renewzle: Solar Tool Connecting Homeowners & Installers'
    @meta_description = 'Brought to you by Renewzle Inc., Renewzle is a green web tool designed to help consumers better understand the financial and environmental effects of solar energy and to help homeowners shop for a solar system that fits their needs. Renewzle is a solar calculator that helps you find the best installer in your area.'
    @meta_keywords = 'renewzle, what is renewzle, greenweb, renewzle solar power tool, green options solar tool, greenweb tool'
    render(:template => 'shared/about')
  end
  
  def privacy_policy
    @view_title = 'Privacy Policy'
    render(:template => 'shared/privacy_policy')
  end
  
  def tos
    @view_title = 'Terms of Service'
    render(:template => 'shared/tos')
  end
end
