class NotificationSettingsController < ApplicationController
  layout 'account'

  def index
    @user = current_user

  end

  def update
      @user = current_user
      if @user.update_attribute(:notify_on_trade, params[:user][:notify_on_trade])
        redirect_to notification_settings_path, :notice => t("notification_settings.notice_updated")
      else
        render :action => :index
      end
  end

end