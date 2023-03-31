module Spree
  module CheckoutControllerDecorator
    def self.prepended(base)
      base.before_action :pay_with_edenred, only: :update
      base.before_action :validate_edenred_btn, only: %i[edit update]
    end

    private

    def validate_edenred_btn
      return false unless @order.payment?

      @hide_edenred_btn = @order.includes_products_not_authorized_by_edenred?
    end

    def pay_with_edenred
      return unless params[:state] == 'payment'
      return if params[:order].blank? || params[:order][:payments_attributes].blank?

      pm_id = params[:order][:payments_attributes].first[:payment_method_id]
      payment_method = Spree::PaymentMethod.find(pm_id)

      if payment_method && (payment_method.kind_of?(Spree::PaymentMethod::Edenred) ||
        payment_method.kind_of?(Spree::PaymentMethod::EdenredJunaeb))
        payment_number = edenred_create_payment(payment_method)
        edenred_error && return unless payment_number.present?

        redirect_to payment_method.authorize_code_url
      end
    end

    def edenred_create_payment(payment_method)
      payment = @order.payments.build(payment_method_id: payment_method.id, amount: @order.total_to_edenred, state: 'checkout')

      unless payment.save
        flash[:error] = payment.errors.full_messages.join("\n")
        redirect_to checkout_state_path(@order.state) && return
      end

      unless payment.pend!
        flash[:error] = payment.errors.full_messages.join("\n")
        redirect_to checkout_state_path(@order.state) && return
      end

      payment.number
    end

    def edenred_error(e = nil)
      @order.errors[:base] << "edenred error #{e.try(:message)}"
      render :edit
    end
  end
end

::Spree::CheckoutController.prepend Spree::CheckoutControllerDecorator
