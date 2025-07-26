class ApplicationMailer < ActionMailer::Base
  default from: Settings.email.from_address
  layout "mailer"
end
