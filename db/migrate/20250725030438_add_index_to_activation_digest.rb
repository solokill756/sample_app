class AddIndexToActivationDigest < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :activation_digest, unique: true
  end
end
