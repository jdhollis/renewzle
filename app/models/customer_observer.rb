class CustomerObserver < ActiveRecord::Observer
  def after_create(customer)
    #CustomerNotifier.deliver_verification_to(customer)
    CustomerNotifier.deliver_registration_confirmation_to(customer)
  end
  
  def after_destroy(customer)
    CustomerNotifier.deliver_cancellation_confirmation_to(customer)
  end
end
