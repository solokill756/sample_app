module ApplicationHelper
  def full_title page_title = ""
    base_title = Settings.app.name

    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def user_name user_name = ""
    user_name.empty? ? t("helper.user") : user_name
  end

  def language_switch_link
    if I18n.locale == :en
      link_to t(:switch_to_vietnamese), request.params.merge(locale: :vi),
              class: "nav-link text-white"
    else
      link_to t(:switch_to_english), request.params.merge(locale: :en),
              class: "nav-link text-white"
    end
  end
end
