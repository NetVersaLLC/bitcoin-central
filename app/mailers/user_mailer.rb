@email_config = YAML::load(File.read(File.join(Rails.root, "config", "mail.yml")))[Rails.env]

ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
  :address              => @email_config['address'],
  :port                 => @email_config['port'],
  :domain               => @email_config['domain'],
  :user_name            => @email_config['user_name'],
  :password             => @email_config['password'],
  :authentication       => @email_config['authentication'],
  :enable_starttls_auto => @email_config['enable_starttls_auto'] 
  }

class UserMailer < BitcoinCentralMailer
  def registration_confirmation(user)
    @user = user
    
    mail :to => user.email,
      :subject => (I18n.t :sign_up_confirmation)
  end

  def reset_password_instructions(user)
    @resource = user
    mail :to => user.email,
      :subject => (I18n.t :reset_password_link)
  end
  
  def invoice_payment_notification(invoice)
    @user = invoice.user
    @invoice = invoice
    
    mail :to => @user.email,
      :subject => I18n.t("emails.invoice_payment_notification.subject")
  end
  
  def withdrawal_processed_notification(withdrawal)
    @user = withdrawal.account
    @withdrawal = withdrawal
    
    mail :to => @user.email,
      :subject => I18n.t("emails.withdrawal_processed_notification.subject")
  end
  
  def trade_notification(user, sales, purchases)
    @sales = sales
    @purchases = purchases
    
    mail :to => user.email,
      :subject => I18n.t("emails.trade_notification.subject")
  end

  def send_cancel_message(user, message, amount_currency)
    @message = message
    @amount_currency = amount_currency

    mail :to => user.email,
      :subject => 'Withdrawal request has been declined'
  end

end
