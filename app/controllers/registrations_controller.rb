class RegistrationsController < Devise::RegistrationsController
  def create
    build_resource
    
    resource.email = params[:user][:email]
    
    resource.captcha_checked(verify_recaptcha)

    if resource.save
      redirect_to root_path,
        :notice => t("devise.registrations.signed_up")
    else
      clean_up_passwords(resource)
      render_with_scope :new
    end
  end
end
