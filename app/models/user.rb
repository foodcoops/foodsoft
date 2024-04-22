require 'digest/sha1'
# specific user rights through memberships (see Group)
class User < ApplicationRecord
  include CustomFields
  # TODO: acts_as_paraniod ??

  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships
  # has_one :ordergroup, :through => :memberships, :source => :group, :class_name => "Ordergroup"
  def ordergroup
    Ordergroup.joins(:memberships).where(memberships: { user_id: id }).first
  end

  has_many :workgroups, through: :memberships, source: :group, class_name: 'Workgroup'
  has_many :assignments, dependent: :destroy
  has_many :tasks, through: :assignments
  has_many :send_messages, class_name: 'Message', foreign_key: 'sender_id'
  has_many :created_orders, class_name: 'Order', foreign_key: 'created_by_user_id', dependent: :nullify
  has_many :mail_delivery_status, class_name: 'MailDeliveryStatus', foreign_key: 'email', primary_key: 'email'

  attr_accessor :create_ordergroup, :password, :send_welcome_mail, :settings_attributes

  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :undeleted, -> { where(deleted_at: nil) }

  # makes the current_user (logged-in-user) available in models
  cattr_accessor :current_user

  validates :email, presence: true
  validates :password, presence: { on: :create }
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :email, uniqueness: { case_sensitive: false }
  validates :first_name, presence: true # for simple_form validations
  validates :first_name, length: { in: 2..50 }
  validates :password, confirmation: true
  validates :password, length: { in: 5..50, allow_blank: true }
  # allow nick to be nil depending on foodcoop config
  # TODO Rails 4 may have a more beautiful way
  #   http://stackoverflow.com/questions/19845910/conditional-allow-nil-part-of-validation
  validates :nick, length: { in: 2..25, allow_nil: true, unless: proc { FoodsoftConfig[:use_nick] } }
  validates :nick, length: { in: 2..25, allow_nil: false, if: proc { FoodsoftConfig[:use_nick] } }
  validates :nick, uniqueness: { case_sensitive: false, allow_nil: true } # allow_nil in length validation
  validates :iban, format: { with: /\A[A-Z]{2}[0-9]{2}[0-9A-Z]{,30}\z/, allow_blank: true }
  validates :iban, uniqueness: { case_sensitive: false, allow_blank: true }

  before_validation :set_password
  after_initialize do
    unless settings.profile
      settings.defaults['profile'] = { 'language' => FoodsoftConfig[:default_locale] || I18n.default_locale } unless settings.profile
      if FoodsoftConfig[:profile_data_public_by_default]
        settings.defaults['profile']['phone_is_public'] = true
        settings.defaults['profile']['email_is_public'] = true
        settings.defaults['profile']['name_is_public'] = true
      end
    end
    settings.defaults['messages'] = { 'send_as_email' => true } unless settings.messages
    settings.defaults['notify']   = { 'upcoming_tasks' => true } unless settings.notify
  end

  before_save do
    if send_welcome_mail?
      self.reset_password_token = new_random_password(16)
      self.reset_password_expires = Time.now.advance(days: 2)
    end
  end

  after_save do
    if settings_attributes
      settings_attributes.each do |key, value|
        value.each do |k, v|
          case v
          when '1'
            value[k] = true
          when '0'
            value[k] = false
          end
        end
        settings.merge!(key, value)
      end
    end

    if ActiveModel::Type::Boolean.new.cast(create_ordergroup)
      og = Ordergroup.new({ name: name })
      og.memberships.build({ user: self })
      og.save!
    end

    Mailer.welcome(self).deliver_now if send_welcome_mail?
  end

  def send_welcome_mail?
    ActiveModel::Type::Boolean.new.cast(send_welcome_mail)
  end

  # sorted by display name
  def self.natural_order
    # would be sensible to match ApplicationController#show_user
    if FoodsoftConfig[:use_nick]
      order('nick')
    else
      order('first_name', 'last_name')
    end
  end

  # search by (nick)name
  def self.natural_search(q)
    q = q.strip
    users = User.arel_table
    # full string as nickname
    match_nick = users[:nick].matches("%#{q}%")
    # or each word matches either first or last name
    match_name = q.split.map do |a|
      users[:first_name].matches("%#{a}%").or users[:last_name].matches("%#{a}%")
    end.reduce(:and)
    User.where(match_nick.or(match_name))
  end

  def locale
    settings.profile['language']
  end

  def name
    [first_name, last_name].join(' ')
  end

  def receive_email?
    settings.messages['send_as_email'] && email.present?
  end

  # Sets the user's password. It will be stored encrypted along with a random salt.
  def set_password
    return if password.blank?

    salt = [Array.new(6) { rand(256).chr }.join].pack('m').chomp
    self.password_hash = Digest::SHA1.hexdigest(password + salt)
    self.password_salt = salt
  end

  # Returns true if the password argument matches the user's password.
  def has_password(password)
    Digest::SHA1.hexdigest(password + password_salt) == password_hash
  end

  # Returns a random password.
  def new_random_password(size = 6)
    c = %w[b c d f g h j k l m n p qu r s t v w x z ch cr fr nd ng nk nt ph pr rd sh sl sp st th tr]
    v = %w[a e i o u y]
    f = true
    r = ''
    (size * 2).times do
      r << (f ? c[rand * c.size] : v[rand * v.size])
      f = !f
    end
    r
  end

  # Generates password reset token and sends email
  # @return [Boolean] Whether it succeeded or not
  def request_password_reset!
    self.reset_password_token = new_random_password(16)
    self.reset_password_expires = Time.now.advance(days: 2)
    if save!
      Mailer.reset_password(self).deliver_now
      logger.debug("Sent password reset email to #{email}.")
      true
    else
      false
    end
  end

  # Checks the admin role
  def role_admin?
    groups.detect { |group| group.role_admin? }
  end

  # Checks the finance role
  def role_finance?
    FoodsoftConfig[:default_role_finance] || groups.detect { |group| group.role_finance? }
  end

  # Checks the invoices role
  def role_invoices?
    FoodsoftConfig[:default_role_invoices] || groups.detect { |group| group.role_invoices? }
  end

  # Checks the article_meta role
  def role_article_meta?
    FoodsoftConfig[:default_role_article_meta] || groups.detect { |group| group.role_article_meta? }
  end

  # Checks the suppliers role
  def role_suppliers?
    FoodsoftConfig[:default_role_suppliers] || groups.detect { |group| group.role_suppliers? }
  end

  # Checks the invoices role
  def role_pickups?
    FoodsoftConfig[:default_role_pickups] || groups.detect { |group| group.role_pickups? }
  end

  # Checks the orders role
  def role_orders?
    FoodsoftConfig[:default_role_orders] || groups.detect { |group| group.role_orders? }
  end

  def ordergroup_name
    ordergroup ? ordergroup.name : I18n.t('model.user.no_ordergroup')
  end

  # returns true if user is a member of a given group
  def member_of?(group)
    group.users.exists?(id)
  end

  # Returns an array with the users groups (but without the Ordergroups -> because tpye=>"")
  def member_of_groups
    groups.where(type: '')
  end

  def deleted?
    deleted_at.present?
  end

  def mark_as_deleted
    update_column :deleted_at, Time.now
  end

  def restore
    update_column :deleted_at, nil
  end

  def self.authenticate(login, password)
    user = find_by_nick(login) || find_by_email(login)
    return unless user && password && user.has_password(password)

    user
  end

  def self.custom_fields
    fields = FoodsoftConfig[:custom_fields] && FoodsoftConfig[:custom_fields][:user]
    return [] unless fields

    fields.map(&:deep_symbolize_keys)
  end

  # XXX this is view-related; need to move out things like token_attributes
  #     then this can be removed
  def display
    # would be sensible to match ApplicationHelper#show_user
    if FoodsoftConfig[:use_nick]
      nick.nil? ? I18n.t('helpers.application.nick_fallback') : nick
    else
      name
    end
  end

  def token_attributes
    # would be sensible to match ApplicationController#show_user
    #   this should not be part of the model anyway
    { id: id, name: "#{display} (#{ordergroup.try(:name)})" }
  end

  def self.sort_by_param(param)
    param ||= 'name'

    sort_param_map = {
      'nick' => 'nick',
      'nick_reverse' => 'nick DESC',
      'name' => 'first_name, last_name',
      'name_reverse' => 'first_name DESC, last_name DESC',
      'email' => 'users.email',
      'email_reverse' => 'users.email DESC',
      'phone' => 'phone',
      'phone_reverse' => 'phone DESC',
      'last_activity' => 'last_activity',
      'last_activity_reverse' => 'last_activity DESC',
      'ordergroup' => "IFNULL(groups.type, '') <> 'Ordergroup', groups.name",
      'ordergroup_reverse' => "IFNULL(groups.type, '') <> 'Ordergroup', groups.name DESC"
    }

    # Never pass user input data to Arel.sql() because of SQL Injection vulnerabilities.
    # This case here is okay, as param is mapped to the actual order string.
    eager_load(:groups).order(Arel.sql(sort_param_map[param])) # eager_load is like left_join but without duplicates
  end
end
