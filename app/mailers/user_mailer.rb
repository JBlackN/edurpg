class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def consent_email
    @user = params[:user]
    @code = @user.otp_code
    mail to: "#{@user.username}@fit.cvut.cz",
         subject: 'Souhlas se zpracováním fotografie'
  end
end
