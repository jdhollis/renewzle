module Renewzle
  class CreditCardInvalid < RuntimeError; end
  class PaymentAuthorizationFailed < RuntimeError; end
  class DiscountInvalid < RuntimeError; end
end
