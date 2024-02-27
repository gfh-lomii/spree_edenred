module Spree
  module Edenred
    class SetToken
      prepend Spree::ServiceModule::Base

      def call(order: nil, code: nil, request_mobile: false)
        edenred_user = order.user.edenred_user
        return success(edenred_user.token) if edenred_user.present? && edenred_user.token_available?

        payment_method = order.payments.last.payment_method
        url = URI("https://directpayment.sa.edenred.io/v1/connect/token")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Post.new(url)
        request["Accept"] = 'application/json'
        request["Content-Type"] = 'application/x-www-form-urlencoded'
        params = {
          'grant_type': 'authorization_code',
          'client_id': ENV['EDENRED_CLIENT_ID__AUTH'],
          'client_secret': ENV['EDENRED_CLIENT_SECRET_AUTH'],
          'code': code,
          'redirect_uri': payment_method.preferences[:return_url_login]
        }

        query = URI.encode_www_form(params)

        response = https.request(request, query)
        raise "#{response.read_body.to_s}" if response.code != '200'
          resp = JSON.parse(response.body)
          token = resp['access_token']
          expires_at = Time.current + Time.at(resp['expires_in'].to_i)
          set_token(token, expires_at, request_mobile, order.user_id)
          success(token)
      rescue StandardError => e
        failure(JSON.parse(e.try(:message))['error'] || e.try(:message))
      end

      def set_token(token, expires_at, request_mobile, user_id)
        edenred_user = Spree::EdenredUser.find_by(user_id: user_id)

        if edenred_user
          edenred_user.update(token: token, token_expires_at: expires_at, mobile: request_mobile)
        else
          Spree::EdenredUser.create(token: token, token_expires_at: expires_at, user_id: user_id,
            mobile: request_mobile)
        end
      end
    end
  end
end
