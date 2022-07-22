module Spree
  module Api
    module V2
      module Storefront
        module Account
          class EdenredController < ::Spree::Api::V2::ResourceController
            include Spree::Api::V2::Storefront::OrderConcern
            before_action :ensure_order
            before_action :valite_code
            before_action :load_data

            def pay_with_edenred
              token = Spree::Edenred::SetToken.call(order: @order, code: params[:code])

              if token.success
                @order.reload
                resp_pay = Spree::Edenred::NewPayment.call(order: @order, token: @order.user.edenred_user.token)

                if resp_pay.success
                  @order.skip_stock_validation = true
                  @order.next! unless @order.completed?

                  edenred_notification
                  render json: { success: true, message: @response }
                else
                  edenred_error(resp_pay.value)
                end
              else
                edenred_error(token.value)
              end
            rescue StandardError => e
              edenred_error(e)
            end

            def edenred_notification
              notification = EdenredNotification.find_by(order_id: @order.id, payment_id: @payment.id)
              EdenredNotification.create(order_id: @order.id, payment_id: @payment.id) if notification.blank?
            end

            private

            def load_data
              @order = spree_current_order
              if @order.present?
                @payment = @order.payments.order(:id).last
              else
                render json: { success: false, message: 'order not found' }, state: 404
                return
              end
            end

            def valite_code
              if params[:code].blank?
                render json: { success: false, message: Spree.t(:edenred_code_required) }
                return
              end
            end

            def edenred_error(e = nil)
              render json: { success: false, message: "Edenred error: #{e}" }
            end
          end
        end
      end
    end
  end
end
