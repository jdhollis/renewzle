xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "New Companies"
    xml.description "New Companies"
    xml.link formatted_admin_companies_url(:rss)

    @companies.each do |company|
      xml.item do
        xml.title "New Company - #{company.name}"
        xml.description "New Company - #{company.name}"
        xml.pubDate company.updated_at.to_s(:rfc822)
        xml.link admin_company_url(company)
        xml.guid admin_company_url(company)
      end
    end
  end
end
