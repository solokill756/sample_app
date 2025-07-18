class User < ApplicationRecord
  has_many :microposts, dependent: :destroy

  validates :name, presence: true,
length: {maximum: Settings.models.user.name_max_length}
  validates :email, presence: true,
length: {maximum: Settings.models.user.email_max_length}
end
