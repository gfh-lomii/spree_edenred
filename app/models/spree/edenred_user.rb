module Spree
  class EdenredUser < Spree::Base
    belongs_to :user, class_name: 'Spree::User', foreign_key: :user_id

    def token_available?
      token.present? && !token_expired?
    end

    def token_expired?
      token_expires_at <= Time.current
    end
  end
end
