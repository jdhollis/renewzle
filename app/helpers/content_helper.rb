module ContentHelper
  def google_adwords_quote_conversion_tracker
    render(:partial => 'content/shop/google_adwords_quote_conversion_tracker') if in_production?
  end
end