module Spree
  module OrderDecorator
    # Indica si la orden tiene algun pago con Webpay completado con exito
    #
    # Return TrueClass||FalseClass instance
    def edenred_payment_completed?
      if payments.completed.from_edenred.any?
        true
      else
        false
      end
    end

    def edenred_client_name
      if ship_address
        ship_address.full_name
      else
        "#{user.firstname} #{user.lastname}"
      end
    end

    # Indica si la orden tiene asociado un pago por Edenred
    #
    # Return TrueClass||FalseClass instance
    def has_endenred_payment_method?
      payments.valid.from_endenred.any?
    end

    # Devuelve la forma de pago asociada a la order, se extrae desde el último payment
    #
    # Return Spree::PaymentMethod||NilClass instance
    def edenred_payment_method
      has_edenred_payment_method? ? payments.valid.from_edenred.order(:id).last.payment_method : nil
    end

    # Entrega valor total en formato compatible con el estandar de Edenred (sin decimales)
    #
    # Return String instance
    def total_to_edenred
      total.to_f.ceil
    end

    # Siempre los decimales son 00 y se agregan a al monto existente para enviar a Edenred
    def total_with_decimals_edenred_format
      new_total = "#{total_to_edenred.to_s}00"
      new_total.to_i
    end

    def includes_products_not_authorized_by_edenred?
      return false unless Rails.env.production?
      return true if store&.url.eql?('https://lomiexpress.cl')

      products.map{ |p| p.taxon_ids.include?(2089) }.include?(true)
    end
  end
end

::Spree::Order.prepend Spree::OrderDecorator
