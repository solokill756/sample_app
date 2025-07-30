class Micropost < ApplicationRecord
  MICROPOST_PERMIT = %i(content image).freeze
  IMAGE_PRELOAD = [{image_attachment: :blob}].freeze

  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :display,
                       resize_to_limit: [
                         Settings.models.micropost.image_display_width,
                          Settings.models.micropost.image_display_height
                       ]
  end

  validates :content,
            presence: true,
            length: {
              maximum: Settings.models.micropost.content_max_length
            }
  validates :image, content_type: {
                      in: Settings.models.micropost.image_content_types,
                      message: :invalid_image_type
                    },
                    size: {
                      less_than: Settings.models
                                         .micropost.image_size_limit.megabytes,
                      message: :image_size_exceeded
                    }

  scope :recent, -> {order(created_at: :desc)}
  scope :relate_post, -> (user_ids) {where(user_id: user_ids)}
end
