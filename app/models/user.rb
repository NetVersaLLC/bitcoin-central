class User < Account
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable,
    :ga_otp_authenticatable,
    :yk_otp_authenticatable,
    :registerable,
    :confirmable,
    :recoverable,
    :trackable,
    :validatable,
    :lockable,
    :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :password, :password_confirmation, :remember_me, :time_zone, 
    :merchant, :require_ga_otp, :require_yk_otp, :full_name, :address

  attr_accessor :captcha,
    :skip_captcha,
    :new_password,
    :new_password_confirmation,
    :current_password

  before_validation :generate_name,
    :on => :create

  has_many :trade_orders,
    :dependent => :destroy

  has_many :purchase_trades,
    :class_name => "Trade",
    :foreign_key => "buyer_id"

  has_many :sale_trades,
    :class_name => "Trade",
    :foreign_key => "seller_id"

  has_many :invoices,
    :dependent => :destroy

  has_many :yubikeys,
    :dependent => :destroy

  has_many :bank_accounts,
    :dependent => :destroy

  has_many :tickets,
    :dependent => :destroy

  validates :email,
    :uniqueness => true,
    :presence => true

  validate :captcha do
    if captcha == false and new_record?
      errors[:captcha] << I18n.t("errors.answer_incorrect")
    end
  end

  def captcha_checked(recaptcha_ans)
    self.captcha = recaptcha_ans
  end

  def bitcoin_address
    super or (generate_new_address && super)
  end

  def qr_code
    if @qrcode.nil?
      @qrcode = RQRCode::QRCode.new(bitcoin_address, :size => 6)
    end
    @qrcode
  end

  def confirm!
    super
    UserMailer.registration_confirmation(self).deliver
  end

  def send_reset_password_instructions
    self.reset_password_token = "#{self.id}#{ROTP::Base32.random_base32}"
    self.save
    UserMailer.reset_password_instructions(self).deliver
  end

  protected

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    name = conditions.delete(:name)
    where(conditions).where(["name = :value OR email = :value", { :value => name }]).first
  end

  def generate_name
    self.name = "TB#{"%06d" % (rand * 10 ** 6).to_i}"
  end
end
