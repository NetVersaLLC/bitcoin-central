class PasswordController < ApplicationController # responsible for changing passwords for logged in users
  layout 'account'

  def form
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update_with_password(params[:user]) && !params[:user][:password].blank?
      sign_in(@user, :bypass => true)

      redirect_to notification_settings_path, :notice => "Your password has been updated successfully"
    else
      if params[:user][:password].blank?
        @user.errors.add(:password, :blank)
      end
      render :form
    end
  end
end