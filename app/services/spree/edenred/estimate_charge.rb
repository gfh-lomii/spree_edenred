module Spree
  module Edenred
    class EstimateCharge
      prepend Spree::ServiceModule::Base

      def call(order: nil, token: nil)
        #url = URI("https://directpayment.stg.eu.edenred.io/v2/users/#{order.user.rut}/actions/estimate-charge")
        payment_url = order.payments.last.payment_method.preferences[:payment_url]
        url = URI("#{payment_url}/users/#{order.user.rut}/actions/estimate-charge"")
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
          'amount': order.total_with_decimals_edenred_format
        }.to_json
byebug
        response = https.request(request)
        raise "#{response.read_body.to_s}" if response.code != '200'
          resp = JSON.parse(response.body)
          if resp[:meta][:status].eql?('succeeded')
            available_balance = order.total_with_decimals_edenred_format <= resp[:data][:available_amount]
            available_balance ? success(available_balance) : failure(normalize_amount(resp[:data][:available_amount]))
          else
            failure(resp[:meta][:messages][:code])
          end
      rescue StandardError => e
        failure(e)
      end

      def normalize_amount(amount)
        length = amount.to_s.length
        amount.to_s[0..length-3].to_i if amount.to_s[length-2..length].to_i.eql?(00)
      end
    end
  end
end
