class User < ApplicationRecord
  EAGER_LOAD_ASSOCIATIONS = [:user, Micropost::IMAGE_PRELOAD].freeze

  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: Relationship.name,
           foreign_key: :follower_id, dependent: :destroy
  has_many :passive_relationships, class_name: Relationship.name,
           foreign_key: :followed_id, dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  has_secure_password

  USER_PERMIT_PARAMS = %i(name email password password_confirmation birthday
gender).freeze

  enum gender: {
    male: 0,
    female: 1,
    other: 2
  }, _prefix: true

  attr_accessor :remember_token, :activation_token, :reset_token

  before_save :downcase_email

  before_create :create_activation_digest

  validates :name,
            presence: true,
            length: {maximum: Settings.models.user.name_max_length}
  validates :email,
            presence: true,
            uniqueness: {case_sensitive: false},
            length: {maximum: Settings.models.user.email_max_length},
            format: {with: Settings.models.user.valid_email_regex}
  validates :gender, presence: true
  validates :password,
            presence: true,
            length: {minimum: Settings.models.user.password_min_length},
            allow_nil: true

  validate :birthday_within_last_100_years

  scope :newest, -> {order(created_at: :desc)}

  class << self
    def new_token
      SecureRandom.urlsafe_base64
    end

    def digest string
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
  end

  def feed
    Micropost.relate_post(following_ids << id).includes(EAGER_LOAD_ASSOCIATIONS)
  end

  def forget
    update_column :remember_digest, nil
  end

  def authenticated? attribute, remember_token
    digest_value = public_send("#{attribute}_digest")
    return false if digest_value.nil? || remember_token.nil?

    begin
      BCrypt::Password.new(digest_value).is_password?(remember_token)
    rescue BCrypt::Errors::InvalidHash
      false
    end
  end

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def create_remember_token
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  def password_reset_expired?
    reset_sent_at < Settings.models.user.reset_token_expiration.hours.ago
  end

  def follow other_user
    following << other_user unless following.include?(other_user)
  end

  def unfollow other_user
    following.delete(other_user) if following?(other_user)
  end

  def following? other_user
    following.include?(other_user)
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

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
