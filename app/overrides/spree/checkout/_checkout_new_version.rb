Deface::Override.new(
  virtual_path: 'spree/checkout/_checkout_new_version',
  name: 'edenred_payment_method',
  insert_top: '[data-hook="payment_methods_list"]',
  text: %{
    <% payment_method = current_store&.payment_methods.active.available_on_front_end.find_by_type("Spree::PaymentMethod::Edenred") %>
        <% if payment_method %>
          <% unless current_store&.url.eql?('https://lomiexpress.cl') %>
            <label class="d-block" for="<%= dom_id(payment_method) %>">
              <div class="card-lomi mb-0 edenred">
                <div class="d-flex justify-content-between align-items-center px-1">
                  <div class="d-flex">
                    <div class="icon-lomi boton-rounded mr-3 shadow2-lomi justify-content-center align-items-center" style="width: 41px; height: 41px;">
                      <%= image_tag main_app.url_for(payment_method&.image&.url(:small) || 'icon.png'), class: 'w-100 d-block my-1 rounded-circle' %>
                    </div>
                    <div>
                      <p class="titulo-l-semibold color-dark-blue-lomi mb-1"><%= payment_method.name %></strong></label>
                      <p class="mb-0 texto-s color-grey-lomi"><%= payment_method.description %></p>
                    </div>
                  </div>
                  <input type="radio"
                        id="<%= dom_id(payment_method) %>"
                        name="method"
                        data-action='checkout#selectPaymentMethod'
                        value="<%= payment_method.id %>"
                        data-type="<%= payment_method.type %>"
                        data-title="<%= payment_method.name %>"
                        data-description="<%= payment_method.description %>"
                        data-icon="<%= main_app.url_for(payment_method&.image&.url(:small) || 'icon.png') %>"
                        <%= 'disabled' if @order.any_item_with_alcohol? %>>
                </div>
              </div>
              <% if @order.any_item_with_alcohol? %>
                <p class="ml-4 texto-s"><%= Spree.t(:purchases_with_alcohol_not_allowed, payment_method: 'Edenred')%></p>
              <% end %>
            </label>
          <% end %>
        <% end %>
  }
)
