class StateIncomeTaxBracket < IncomeTaxBracket
  def self.state_filing_status_for(filing_status)
    [ 'Married filing separately', 'Head of household' ].include?(filing_status) ? 'Married' : filing_status
  end
  
  def self.find_by_state_and_filing_status_for_income(state, filing_status, income)
    find_by_state_and_filing_status(state, state_filing_status_for(filing_status), :conditions => [ "income_min <= ? AND (income_max >= ? OR income_max IS NULL)", income, income ])
  end
end