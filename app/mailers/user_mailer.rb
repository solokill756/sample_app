class UserMailer < ApplicationMailer
  def account_activation user
    @user = user

    mail to: user.email, subject: t(".activation_subject")
  end

  def password_reset user
    @user = user

    mail to: user.email, subject: t(".reset_subject")
  end

  def password_reset_success user, new_password
    @new_password = new_password
    @user = user

    mail to: user.email, subject: t(".reset_success_subject")
  end
end
