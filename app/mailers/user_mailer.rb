# User Mailer
#
# Mailer for generating photo consent emails.
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  # Render photo consent e-mail message with one-time authorization code.
  def consent_email
    @user = params[:user]
    @code = @user.otp_code
    mail to: "#{@user.username}@fit.cvut.cz",
         subject: 'Souhlas se zpracováním fotografie'
  end
end
