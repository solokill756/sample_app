module UsersHelper
  # Constants for date selection
  BIRTHDAY_START_YEAR = 1900

  def gravatar_for _user
    gravatar_id = Digest::MD5.hexdigest(@user.email.downcase)
    gravatar_url = "https://www.gravatar.com/avatar/#{gravatar_id}?d=identicon&s=80"
    image_tag(gravatar_url, alt: @user.name, class: "gravatar")
  end

  def gender_options_for_select
    User.genders.map do |key, _value|
      [t(".gender_options.#{key}"), key]
    end
  end
end
