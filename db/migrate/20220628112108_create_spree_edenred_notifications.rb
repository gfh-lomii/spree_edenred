class CreateSpreeEdenredNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_edenred_notifications do |t|
      t.integer :payment_id
      t.integer :order_id
      t.timestamps
    end
  end
end
