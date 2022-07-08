module Spree
  module PaymentDecorator
    def self.prepended(base)
      base.scope :from_edenred, -> { joins(:payment_method).where(spree_payment_methods: {type: PaymentMethod::Edenred.to_s}) }
      base.scope :with_authorization_id, -> { where.not(authorization_id: nil) }
    end

    def edenred?
      self.payment_method.type == Spree::PaymentMethod::Edenred.to_s
    end
  end
end

::Spree::Payment.prepend Spree::PaymentDecorator
