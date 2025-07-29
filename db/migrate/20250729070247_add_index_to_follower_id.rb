class AddIndexToFollowerId < ActiveRecord::Migration[7.0]
  def change
    add_index :relationships, :follower_id
  end
end
