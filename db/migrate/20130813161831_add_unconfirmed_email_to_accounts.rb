class AddUnconfirmedEmailToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :unconfirmed_email, :string
  end
end
