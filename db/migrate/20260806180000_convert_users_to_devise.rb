class ConvertUsersToDevise < ActiveRecord::Migration[8.0]
  def up
    change_table :users, bulk: true do |t|
      t.remove :password_digest if column_exists?(:users, :password_digest)
      t.string :encrypted_password, null: false, default: "" unless column_exists?(:users, :encrypted_password)
      t.string   :reset_password_token unless column_exists?(:users, :reset_password_token)
      t.datetime :reset_password_sent_at unless column_exists?(:users, :reset_password_sent_at)
      t.datetime :remember_created_at unless column_exists?(:users, :remember_created_at)
    end

    add_index :users, :reset_password_token, unique: true unless index_exists?(:users, :reset_password_token)
  end

  def down
    remove_index :users, :reset_password_token if index_exists?(:users, :reset_password_token)

    change_table :users, bulk: true do |t|
      t.remove :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at
      t.string :password_digest, null: false
    end
  end
end
