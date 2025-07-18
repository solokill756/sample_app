class AddIndexToRememberDigest < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :remember_digest, unique: true
  end
end
