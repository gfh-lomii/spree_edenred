module Spree
  class PaymentMethod::Edenred < Spree::PaymentMethod
    preference :merchant_id, :string
    preference :authentication_url, :string
    preference :payment_url, :string
    preference :return_url_login, :string
    preference :return_url_logout, :string

    def authorize_code_url
      "#{preferences[:authentication_url]}/login?ReturnUrl=%2Fconnect%2Fauthorize%2Fcallback%3Fresponse_type%3Dcode%26client_id%3D#{ENV['EDENRED_CLIENT_ID__AUTH']}%26scope%3Dopenid%2520edg-xp-mealdelivery-api%2520offline_access%26redirect_uri%3D#{return_url_login}%26state%3Dd710ce14-ace6-4300-8e58-5877e7b92500%26nonce%3D11df89b0-4bde-4696-a00ed04cf06b9ab2%26acr_values%3Dtenant%253Acl-ben%26ui_locales%3Des#"
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
