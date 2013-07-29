class GauthController < ApplicationController
  layout 'account'

  def index

  end


  def enable
    current_user.require_ga_otp = true
    current_user.save
    redirect_to gauth_path, :notice => t("gauth.notice_enabled")
  end

  def disable
    current_user.require_ga_otp = false
    current_user.save
    redirect_to gauth_path, :notice => t("gauth.notice_disabled")
  end

  def reset
    current_user.generate_ga_otp_secret && current_user.save!
    redirect_to gauth_path,
                :notice => t("gauth.notice_reset")
  end
end