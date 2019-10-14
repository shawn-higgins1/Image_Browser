# frozen_string_literal: true

class AddVerificationsToUsers < ActiveRecord::Migration[6.0]
    def change
        change_table(:users, bulk: true) do |t|
            t.column :reset_password_token, :string
            t.column :reset_password_sent_at, :datetime
            t.column :email_verification_token, :string
            t.column :email_verified, :boolean, default: false
        end
    end
end
