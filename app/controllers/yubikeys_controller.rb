class YubikeysController < ApplicationController
  def index
    @yubikeys = current_user.yubikeys
    @yubikey = Yubikey.new
  end

  def create
    @yubikey = Yubikey.new(:otp => params[:yubikey][:otp])
    @yubikey.user = current_user

    if @yubikey.save
      redirect_to user_yubikeys_path,
        :notice => t("yubikeys.index.created")
    else
      @yubikeys = current_user.yubikeys
      render :action => :index
    end
  end

  def destroy
    current_user.yubikeys.find(params[:id]).destroy
    redirect_to user_yubikeys_path,
      :notice => t("yubikeys.index.destroyed")
  end
end
