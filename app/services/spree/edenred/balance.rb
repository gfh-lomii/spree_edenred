module Spree
  module Edenred
    class Balance
      prepend Spree::ServiceModule::Base

      def call(order, token)
        #url = URI("https://directpayment.stg.eu.edenred.io/v2/users/{{username}}/balances")
        payment_url = order.payments.last.payment_method.preferences[:payment_url]
        url = URI("#{payment_url}/users/#{order.user.rut}/balances")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Get.new(url)
        request['Authorization'] = "Bearer #{token}"
        request['X-Client-Id'] = ENV['EDENRED_CLIENT_ID_PAYMENT']
        request['X-Client-Secret'] = ENV['EDENRED_CLIENT_SECRET_PAYMENT']
        request["Accept"] = 'application/json'
#        request["Content-Type"] = 'application/json'
byebug
        response = https.request(request)
        raise "#{response.read_body.to_s}" if response.code != '200'
          resp = JSON.parse(response.body)
          # authorization_id = resp[:data][:authorization_id]
          # capture_id = resp[:data][:capture_id]
          # status = resp[:data][:status]
          # code = e[:meta][:messages][0][:code]
          # captured_amount = normalize_amount(resp[:data][:captured_amount])
          # order.payments.last.update(state: e[:meta][:status], response_code: code,
          #   number: capture_id, authorization_id: authorization_id)
          # success(status)
      rescue StandardError => e
        # error_code = e[:meta][:messages][0][:code]
        # order.payments.last.update(state: e[:meta][:status], response_code: error_code)
        failure(e)
      end

      def normalize_amount(amount)
        length = amount.to_s.length
        amount.to_s[0..length-3].to_i if amount.to_s[length-2..length].to_i.eql?(00)
      end
    end
  end
end
