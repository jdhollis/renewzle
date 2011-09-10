class FirstLeadDiscount < Discount
  def apply_to(current_price, lead)
    lead.companys_first_lead? ? super : current_price
  end
end