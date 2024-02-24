module Spree
  class PaymentMethod::Edenred < Spree::PaymentMethod
    preference :merchant_id, :string
    preference :authentication_url, :string
    preference :payment_url, :string
    preference :return_url_login, :string
    preference :return_url_logout, :string

    def authorize_code_url
      preferences[:authentication_url]
    end

    def return_url_login
      encode_url = ERB::Util.url_encode(preferences[:return_url_login])
      re_encode_url = ERB::Util.url_encode(encode_url)
      re_encode_url
    end

    def return_url_logout
      encode_url = ERB::Util.url_encode(preferences[:return_url_logout])
      re_encode_url = ERB::Util.url_encode(encode_url)
      re_encode_url
    end

    def provider_class
      self.class
    end

    def self.STATE
      'edenred'
    end

    def self.production?
      'edenred'
    end

    def method_type
      self.class.STATE
    end

    def auto_capture?
      false
    end

    def payment_profiles_supported?
      false
    end

    def payment_method_logo
      ActionController::Base.helpers.asset_path("edenred_logo.png")
    end

    def logo
      payment_method_logo
    end

    def cancel(*)
    end

    def source_required?
      false
    end

    def success?
      true
    end

    def authorization
      self
    end

    def available_for_order?(_order)
      return false unless _order.user.present?
      return false if _order.amount.to_f < 1000
      return false if _order.products.with_alcohol_restriction.exists?

      true
    rescue
      return true
    end

    def pay(order)
      if balance
      else
      end      
    end

    def validate_balance
      
    end
  end
end
