class AddAuthorizationIdToSpreePayments < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_payments, :authorization_id, :string
  end
end
