xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "New Quotes"
    xml.description "New Quotes"
    xml.link formatted_admin_quotes_url(:rss)

    @quotes.each do |quote|
      xml.item do
        xml.title "New quote for #{quote.profile.customer.full_name}"
        xml.description "New quote for #{quote.profile.customer.full_name}"
        xml.pubDate quote.created_at.to_s(:rfc822)
        xml.link admin_quote_url(quote)
        xml.guid admin_quote_url(quote)
      end
    end
  end
end
