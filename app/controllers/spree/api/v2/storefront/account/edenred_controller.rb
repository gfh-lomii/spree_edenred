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
            before_action :build_payment_method, only: %i[pay_with_edenred]

            def pay_with_edenred
              token = Spree::Edenred::SetToken.call(order: @order, code: params[:code])

              if token.success
                @order.reload
                resp_pay = Spree::Edenred::NewPayment.call(order: @order,
                  token: @order.user.edenred_user.token)

                if resp_pay.success
                  @order.skip_stock_validation = true
                  @order.next! unless @order.completed?

                  EdenredNotification.find_or_create_by(order_id: @order.id, payment_id: @payment.id)
                  render json: { success: true, message: resp_pay.value }
                else
                  edenred_error(resp_pay.value)
                end
              else
                edenred_error(token.value)
              end
            rescue StandardError => e
              edenred_error(e)
            end

            private

            def build_payment_method
              payment_method = Spree::PaymentMethod.find_by(type: 'Spree::PaymentMethod::Edenred')
              payment = @order.payments.build(payment_method_id: payment_method.id,
                amount: @order.total_to_edenred, state: 'checkout')

              unless payment.save
                raise "#{Spree.t(:cant_create_payment)} #{@payment.errors.full_messages.join("\n")}"
              end

              unless payment.pend!
                raise "#{Spree.t(:cant_create_payment_pend)} #{@payment.errors.full_messages.join("\n")}"
              end
            end

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
