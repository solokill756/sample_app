module SessionsHelper
  def log_in user
    user.remember
    session[:user_id] = user.id
    session[:remember_token] = user.remember_token
  end

  def current_user
    if (user_id = session[:user_id]) &&
       (remember_token = session[:remember_token])
      user = User.find_by(id: user_id)

      if user&.try(:authenticated?, remember_token)
        @current_user ||= user
      else
        session.clear
        @current_user = nil
      end
    else
      @current_user = nil
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    current_user&.try(:forget)
    session.clear
    @current_user = nil
  end
end
