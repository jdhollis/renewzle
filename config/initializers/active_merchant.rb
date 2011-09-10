# This initializer loads up the proper gateway based on the environment currently running.
#
# These are test credit card numbers that can be used for testing purposes with the Authorize.net gateway
# 370000000000002 - American Express Test Card
# 6011000000000012 - Discover Test Card
# 5424000000000015 - MasterCard Test Card
# 4007000000027 - Visa Test Card
# 4012888818888 - Visa Test Card II
# 3088000000000017 - JCB Test Card (Use expiration date 0905)
# 38000000000006 - Diners Club/Carte Blanche Test (Use expiration date 0905) 
#
# To test with the Bogus gateway use the number 1 for a success and the number 2 for a failure

AUTHORIZE_NET_LOGIN = ''
AUTHORIZE_NET_PASSWORD = ''

class AuthorizationError < StandardError; end
class CaptureError < StandardError; end

case RAILS_ENV
	when 'test'
		$gateway = ActiveMerchant::Billing::BogusGateway.new
	when 'development'
		$gateway = ActiveMerchant::Billing::AuthorizedNetGateway.new :login => AUTHORIZE_NET_LOGIN, :password => AUTHORIZE_NET_PASSWORD, :test => true
	when 'production'
		$gateway = ActiveMerchant::Billing::AuthorizedNetGateway.new :login => AUTHORIZE_NET_LOGIN, :password => AUTHORIZE_NET_PASSWORD, :test => false
end
