class RetailerContentController < ApplicationController
  before_filter :validate_login_credentials_if_any
  before_filter :setup_masquerade_assigns
  
  def faq
    @view_title = 'Frequently Asked Questions from Solar Retailers'
    @meta_description = 'Have questions about how your solar business can get more customers with Renewzle? Our FAQ covers cost, lead volume, handling quote requests, interacting with the customer, and more.'
    @meta_keywords = 'renewzle frequently asked questions, renewzle faq, solar power faq, solar system size, solar financial analysis, solar panel rfp'
    
    if @user.nil? || (!@user.kind_of?(Partner) && !@user.masquerading_as?(Partner))
      render(:layout => 'pre_signup_partner')
    else
      render(:layout => 'partner')
    end
  end
  
  def help
    @view_title = 'How to Use Renewzle to Grow Your Solar Business: Instructions for Retailers &amp; Installers'
    @meta_description = 'Learn how to sign up for Renewzle and use it to find highly qualified residential solar leads. This document walks you step-by-step through the process of using Renewzle to find customers for your solar business.'
    
    if @user.nil? || (!@user.kind_of?(Partner) && !@user.masquerading_as?(Partner))
      render(:layout => 'pre_signup_partner')
    else
      render(:layout => 'partner')
    end
  end
end