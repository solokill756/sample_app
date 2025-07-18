class Micropost < ApplicationRecord
  belongs_to :user

  validates :content, presence: true,
length: {maximum: Settings.models.micropost.content_max_length}

  scope :recent, ->{order(created_at: :desc)}
end
