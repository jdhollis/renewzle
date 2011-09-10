xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "New Leads"
    xml.description "New Leads"
    xml.link formatted_admin_leads_url(:rss)

    @leads.each do |lead|
      xml.item do
        xml.title "New lead for #{lead.profile.customer.full_name}"
        xml.description "New lead for #{lead.profile.customer.full_name}"
        xml.pubDate lead.created_at.to_s(:rfc822)
        xml.link admin_lead_url(lead)
        xml.guid admin_lead_url(lead)
      end
    end
  end
end
