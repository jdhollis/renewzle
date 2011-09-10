class AdminController < ApplicationController
	layout 'admin'

  before_filter :validate_login_credentials_if_any
	before_filter :verify_user_is_admin
	before_filter :set_timezone

private

	def set_timezone
    Time.zone = @user.time_zone
	end

	def verify_user_is_admin
		verify_user_is(Administrator)
	end
end
