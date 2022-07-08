module Spree::UserDecorator
  def self.prepended(base)
    base.has_one :edenred_user, class_name: 'Spree::EdenredUser', foreign_key: :user_id
  end
end

Spree::User.prepend Spree::UserDecorator
