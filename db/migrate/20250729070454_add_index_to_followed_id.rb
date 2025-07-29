class AddIndexToFollowedId < ActiveRecord::Migration[7.0]
  def change
    add_index :relationships, :followed_id
  end
end
