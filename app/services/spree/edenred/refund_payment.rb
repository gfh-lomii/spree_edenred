module Spree
  module Edenred
    class RefundPayment
      prepend Spree::ServiceModule::Base

      def call(order: nil, token: nil)        
        response = refund_payment_request(order, token)
        raise "#{response.read_body.to_s}" if response.code != '200'
          refund_payment(response, order)
      rescue StandardError => e
        error_payement(order, e)
      end

      def refund_payment_request(order, token)
        authorization_id = order.payments.with_authorization_id.last.authorization_id
        payment_url = order.payments.last.payment_method.preferences[:payment_url]
        url = URI("#{payment_url}/transactions/#{authorization_id}/actions/refund")
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
          "amount": order.total_with_decimals_edenred_format
        }.to_json

        https.request(request)
      end

      def refund_payment(response, order)
        resp = JSON.parse(response.body)
        byebug
        # authorization_id = resp['data']['authorization_id']
        # capture_id = resp['data']['capture_id']
        # status = resp['meta']['status']
        # captured_amount = normalize_amount(resp['data']['captured_amount'])

        # order.payments.last.complete!
        # order.payments.last.update(number: capture_id, authorization_id: authorization_id)
        # success(resp['data']['status'])
        success(true)
      end

      def error_payement(order, e)
        byebug
        error = JSON.parse(e.try(:message))
        payment = order.payments.last
        error_code = error['meta']['messages'].map{ |m| m['text']}.join(" \n")

        payment.update(response_code: error_code)
        payment.failure!
        failure(error_code)
      end

      def normalize_amount(amount)
        length = amount.to_s.length
        amount.to_s[0..length-3].to_i if amount.to_s[length-2..length].to_i.eql?(00)
      end
    end
  end
end
