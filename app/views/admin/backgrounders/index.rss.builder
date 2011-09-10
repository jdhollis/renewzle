xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "New Company Backgrounders"
    xml.description "New Company Backgrounders to approve"
    xml.link formatted_admin_backgrounders_url(:rss)

    @company_backgrounders.each do |backgrounder|
      xml.item do
        xml.title "New Company Backgrounder - '#{backgrounder.title}' for #{backgrounder.company.name}"
        xml.description "#{backgrounder.doc.filename} (#{number_to_human_size(backgrounder.doc.size)}, #{backgrounder.doc.content_type}) was uploaded by #{backgrounder.partner.first_name} #{backgrounder.partner.last_name} (#{backgrounder.partner.email})"
        xml.pubDate backgrounder.created_at.to_s(:rfc822)
      end
    end
  end
end
