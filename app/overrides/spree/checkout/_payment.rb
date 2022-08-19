Deface::Override.new(
  virtual_path: 'spree/checkout/_payment',
  name: 'edenred_payment_method',
  insert_top: '[data-hook="payment_methods_li"]',
  text: %{
    <% if method.type.eql?('Spree::PaymentMethod::Edenred') %>
      <% next if !@ld_client.variation("edenred-payment-web", @ld_user, true) %>
      <% next if @hide_edenred_btn %>
    <% end %>
  }
)
