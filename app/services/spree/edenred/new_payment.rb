module Spree
  module Edenred
    class NewPayment
      prepend Spree::ServiceModule::Base

      def call(order: nil, token: nil)
        response = new_payment_request(order, token)
        raise "#{response.read_body.to_s}" if response.code != '200'
          new_payment(response, order)
      rescue StandardError => e
        error_payement(order, e)
      end

      def new_payment_request(order, token)
        preferences = order.payments.last.payment_method.preferences
        payment_url = 'https://sso.edenred.io' # preferences[:payment_url]
        url = URI("#{payment_url}/v2/transactions")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{token}"
        request['X-Client-Id'] = ENV['EDENRED_CLIENT_ID_PAYMENT']
        request['X-Client-Secret'] = ENV['EDENRED_CLIENT_SECRET_PAYMENT']
        request["Accept"] = 'application/json'
        request["Content-Type"] = 'application/json'
        request.body = {
          "mid": preferences[:merchant_id],
          "order_ref": order.number,
          "amount": order.total_with_decimals_edenred_format,
          "capture_mode": "auto",
          "security_level": "standard",
          "currency": "CLP",
          "tstamp": DateTime.current
        }.to_json

        https.request(request)
      end

      def new_payment(response, order)
        resp = JSON.parse(response.body)
        authorization_id = resp['data']['authorization_id']
        capture_id = resp['data']['capture_id']
        status = resp['meta']['status']
        captured_amount = normalize_amount(resp['data']['captured_amount'])

        order.payments.last.complete!
        order.payments.last.update(number: capture_id, authorization_id: authorization_id)
        success(resp['data']['status'])
      end

      def error_payement(order, e)
        error = JSON.parse(e.try(:message))
        payment = order.payments.last
        error_code = error['meta']['messages'].map{ |m| m['code']}.join(" \n")
        error_code_t = error['meta']['messages'].map{ |m| Spree.t("edenred.#{m['code']}")}.join(" \n")

        payment.update(response_code: error_code)
        payment.failure!
        failure(error_code_t)
      end

      def normalize_amount(amount)
        length = amount.to_s.length
        amount.to_s[0..length-3].to_i if amount.to_s[length-2..length].to_i.eql?(00)
      end
    end
  end
end
