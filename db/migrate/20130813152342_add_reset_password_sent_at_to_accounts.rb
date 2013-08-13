class AddResetPasswordSentAtToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :reset_password_sent_at, :datetime
  end
end
