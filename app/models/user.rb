class User < ApplicationRecord
  has_secure_password

  attr_accessor :remember_token

  has_many :microposts, dependent: :destroy

  USER_PERMIT_PARAMS = %i(name email password password_confirmation birthday
gender).freeze

  enum gender: {
    male: 0,
    female: 1,
    other: 2
  }, _prefix: true

  before_save :downcase_email

  validates :name,
            presence: true,
            length: {maximum: Settings.models.user.name_max_length}
  validates :email,
            presence: true,
            uniqueness: {case_sensitive: false},
            length: {maximum: Settings.models.user.email_max_length},
            format: {with: Settings.models.user.valid_email_regex}
  validates :gender, presence: true
  validate :birthday_within_last_100_years

  class << self
    def new_token
      SecureRandom.urlsafe_base64
    end

    def digest string
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
  end

  def forget
    update_column :remember_digest, nil
  end

  def authenticated? remember_token
    return false if remember_digest.nil? || remember_token.nil?

    begin
      BCrypt::Password.new(remember_digest).is_password?(remember_token)
    rescue BCrypt::Errors::InvalidHash
      false
    end
  end

  def create_remember_token
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  private

  def downcase_email
    email.downcase!
  end

  def birthday_within_last_100_years
    return if birthday.blank?

    birthday_date = parse_birthday_date
    return if birthday_date.nil?

    validate_future_birthday(birthday_date)
    validate_past_birthday(birthday_date)
  end

  def parse_birthday_date
    birthday.is_a?(Date) ? birthday : Date.parse(birthday.to_s)
  rescue ArgumentError
    errors.add(:birthday, :invalid)
    nil
  end

  def validate_future_birthday birthday_date
    return unless birthday_date > Time.zone.today

    errors.add(:birthday, :future)
  end

  def validate_past_birthday birthday_date
    min_date = Settings.models.user.year_of_past.years.ago.to_date
    return unless birthday_date < min_date

    errors.add(:birthday, :past_one_hundred)
  end
end
