class CreateSpreeEdenredUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_edenred_users do |t|
      t.text :token
      t.datetime :token_expires_at
      t.boolean :mobile, default: false
      t.integer :user_id
      t.timestamps
    end
  end
end
