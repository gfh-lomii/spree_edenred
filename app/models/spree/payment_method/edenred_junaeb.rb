module Spree
  class PaymentMethod::EdenredJunaeb < Spree::PaymentMethod::Edenred
    def authorize_code_url
      "#{preferences[:authentication_url]}/login?returnUrl=%2Fconnect%2Fauthorize%2Fcallback%3Fresponse_type%3Dcode%26client_id%3D#{ENV['EDENRED_CLIENT_ID__AUTH']}%26scope%3Dopenid%2520edg-xp-mealdelivery-api%2520offline_access%26redirect_uri%3D#{return_url_login}%26state%3Dd710ce14-ace6-4300-8e58-5877e7b92500%26nonce%3D11df89b0-4bde-4696-a00ed04cf06b9ab2%26acr_values%3Dtenant%253Acl-ben-junaeb%26ui_locales%3Des#"
    end

    def payment_method_logo
      ActionController::Base.helpers.asset_path("edenred_junaeb_logo.png")
    end
  end
end
