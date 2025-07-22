class User < ApplicationRecord
  has_secure_password

  has_many :microposts, dependent: :destroy

  before_save :downcase_email

  validates :name,
            presence: true,
            length: {maximum: Settings.models.user.name_max_length}
  validates :email,
            presence: true,
            uniqueness: {case_sensitive: false},
            length: {maximum: Settings.models.user.email_max_length},
            format: {with: Settings.models.user.valid_email_regex}
  validate :birthday_within_last_100_years

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
