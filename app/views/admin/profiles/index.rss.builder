xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "New Profiles"
    xml.description "New Profiles"
    xml.link formatted_admin_profiles_url(:rss)

    @profiles.each do |profile|
      xml.item do
        xml.title "New profile for #{profile.customer.full_name}"
        xml.description "New profile for #{profile.customer.full_name}"
        xml.pubDate profile.created_at.to_s(:rfc822)
        xml.link admin_profile_url(profile)
        xml.guid admin_profile_url(profile)
      end
    end
  end
end
