module SSL
  def require_ssl
    request.env['HTTPS'] = 'on'
  end
end