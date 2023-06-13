Deface::Override.new(
  virtual_path: 'spree/checkout/_payment_methods',
  name: 'edenred_payment_method',
  insert_top: '[data-hook="payment_methods_li"]',
  text: %{
    <% if method.type.eql?('Spree::PaymentMethod::Edenred') %>
      <% next if current_store&.url.eql?('https://lomiexpress.cl') %>
      <% next if !@ld_client.variation("edenred-payment-web", @ld_user, true) %>
      <% next if @hide_edenred_btn %>
    <% end %>
    <% if Rails.env.production? && @order.payments&.last&.edenred? %>
      <script>
        var spans = Array.from(document.querySelectorAll('span'));

        var edenred_error = spans.find(span => (span.textContent.toLowerCase().includes('edenred error')));

        if (edenred_error !== undefined) {
          window.analytics.track('transaction_error_edenred.loaded')
        }
      </script>
    <% end %>
  }
)
