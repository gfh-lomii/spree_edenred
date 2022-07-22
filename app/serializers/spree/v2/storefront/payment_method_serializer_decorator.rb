module Spree
  module V2
    module Storefront
      module PaymentMethodSerializerDecorator
        def self.prepended(base)
          base.attributes :login_url do |payment_method|
            if payment_method.type.eql?('Spree::PaymentMethod::Edenred')
              payment_method.authorize_code_url
            else
              nil
            end
          end
        end
      end
    end
  end
end

Spree::V2::Storefront::PaymentMethodSerializer.prepend Spree::V2::Storefront::PaymentMethodSerializerDecorator
