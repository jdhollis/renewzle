class FederalIncomeTaxBracket < IncomeTaxBracket
  def self.find_by_filing_status_for_income(filing_status, income)
    find_by_filing_status(filing_status, :conditions => [ "income_min <= ? AND (income_max >= ? OR income_max IS NULL)", income, income ])
  end
end