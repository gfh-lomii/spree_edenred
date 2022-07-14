Deface::Override.new(
  virtual_path: 'spree/checkout/_payment',
  name: 'edenred_payment_method',
  insert_top: '[data-hook="payment_methods_li"]',
  text: %{
    <% isEdenred = method.type.eql?('Spree::PaymentMethod::Edenred') %>
    <% next if isEdenred && !@ld_client.variation("edenred-payment", @ld_user, true) %>
  }
)
