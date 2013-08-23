class RegistrationsController < Devise::RegistrationsController

  def create
    if verify_recaptcha
      super
    else
      build_resource(sign_up_params)
      resource.valid? # required to display errors
      resource.errors[:captcha] = I18n.t("errors.answer_incorrect")
      clean_up_passwords(resource)
      render :new
    end
  end

end
