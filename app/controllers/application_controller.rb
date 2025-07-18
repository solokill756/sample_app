class ApplicationController < ActionController::Base
  before_action :set_locale

  private

  def set_locale
    I18n.locale = if params[:locale].present? &&
                     I18n.available_locales.map(&:to_s)
                         .include?(params[:locale])
                    params[:locale]
                  else
                    Settings.i18n.default_locale
                  end
  end

  def default_url_options
    {locale: I18n.locale}
  end
end
