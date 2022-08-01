module Spree
  module V2
    module Storefront
      module CartSerializerDecorator
        def self.prepended(base)
          base.attributes :hide_edenred_btn do |cart|
            cart.includes_products_not_authorized_by_edenred?
          end
        end
      end
    end
  end
end

Spree::V2::Storefront::CartSerializer.prepend Spree::V2::Storefront::CartSerializerDecorator
