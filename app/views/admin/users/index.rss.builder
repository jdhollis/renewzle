xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "New Users"
    xml.description "New Users"
    xml.link formatted_admin_users_url(:rss)

    @users.each do |user|
      xml.item do
        xml.title "New #{user.type} - #{user.full_name}"
        xml.description "New #{user.type} - #{user.full_name}"
        xml.pubDate user.created_at.to_s(:rfc822)
        xml.link admin_user_url(user)
        xml.guid admin_user_url(user)
      end
    end
  end
end
