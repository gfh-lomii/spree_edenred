module Spree
  class EdenredController < StoreController
    before_action :valite_call_provider
    before_action :load_data
    before_action :valite_code
    before_action :validate_payment_state

    def login
      token = Spree::Edenred::SetToken.call(order: @order, code: params[:code])

      if token.success
        @order.reload
        resp_pay = Spree::Edenred::NewPayment.call(order: @order, token: @order.user.edenred_user.token)

        if resp_pay.success
          @order.skip_stock_validation = true
          @order.next! unless @order.completed?

          edenred_notification
          completion
        else
          error(resp_pay.value)
        end
      else
        error(token.value)
      end
    end

    def logout
      redirect_to root_path
    end

    def edenred_notification
      unless EdenredNotification.find_by(order_id: @order.id, payment_id: @payment.id)
        flash.notice = Spree.t(:order_processed_successfully)
        flash['order_completed'] = true
      end

      EdenredNotification.create(order_id: @order.id, payment_id: @payment.id)
    end

    def valite_call_provider
      if current_order || spree_current_user
        true
      else
        render json: { status: :ok, code: params[:code] }
      end
    end

    private

    def load_data
      @order = current_order || spree_current_user.orders.last || raise(ActiveRecord::RecordNotFound)
      @payment = @order.payments.order(:id).last
    end

    def valite_code
      redirect_to root_path if params[:code].blank?
    end

    def validate_payment_state
      flash[:error] = Spree.t(:validate_payment_state_edenred)
      redirect_to root_path unless @order.payment?
    end

    def completion
      redirect_to spree.order_path(id: @order.number)
      return
    end

    def error(e = nil)
      flash[:error] = "Edenred error: #{e}"
      redirect_to checkout_state_path(@order.state)
      return
    end
  end
end
