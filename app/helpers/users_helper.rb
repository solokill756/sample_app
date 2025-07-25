module UsersHelper
  BIRTHDAY_START_YEAR = 1900

  def gravatar_for user, options = {size: Settings.dig(:users, :avatar_size)}
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end

  def gender_options_for_select
    User.genders.map do |key, _value|
      [t("users.form.gender.#{key}"), key]
    end
  end

  def submit_text
    case action_name.to_sym
    when :new, :create
      t("users.new.submit")
    when :edit, :update
      t("users.edit.submit")
    else
      t("users.form.submit")
    end
  end

  def url_form
    @user.new_record? ? users_path : user_path(@user)
  end

  # Helper method cho admin delete link
  def admin_delete_link user
    return if current_user?(user) || !current_user.admin?

    content_tag :span, class: "admin-actions ms-2" do
      concat " | "
      concat link_to(t("users.index.delete"),
                     user_path(user),
                     method: :delete,
                     class: "text-danger text-decoration-none",
                     data: {
                       "turbo-method": :delete,
                       "turbo-confirm": t("users.index.delete_confirm")
                     })
    end
  end
end
