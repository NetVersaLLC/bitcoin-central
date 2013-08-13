class RemoveRememberTokenFromAccounts < ActiveRecord::Migration
  def up
    remove_column :accounts, :remember_token
  end

  def down
    add_column :accounts, :remember_token, :string
  end
end
