module SessionsHelper
  def log_in user
    session[:user_id] = user.id
    session[:session_token] = user.remember_token
  end

  def current_user
    @current_user ||= user_from_cookies || user_from_session
  end

  def current_user? user
    user == current_user
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    current_user&.forget
    clear_data
    @current_user = nil
  end

  def remember_cookies user
    user.create_remember_token
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user&.remember_token
  end

  def clear_data
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
    session.delete(:user_id)
    session.delete(:session_token)
  end

  def user_from_cookies
    user_id = cookies.signed[:user_id]
    remember_token = cookies[:remember_token]
    return nil unless user_id && remember_token

    user = User.find_by(id: user_id)
    user if user&.authenticated?(:remember, remember_token)
  end

  def user_from_session
    user_id = session[:user_id]
    session_token = session[:session_token]
    return nil unless user_id && session_token

    user = User.find_by(id: user_id)
    user if user&.authenticated?(:remember, session_token)
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
