class Api::V1::Admin::UsersController < Api::V1::BaseController
  include Concerns::CollectionScope

  before_action -> { doorkeeper_authorize! 'user:read', 'user:write' }

  def index
    render json: search_scope, each_serializer: UserAlldataSerializer, meta: collection_meta(search_scope)
  end

  def show
    @users_scope = :all
    @user = find_user_by_id
    render_data
  end

  def create
    check_params
    @user = User.new(params[:user])
    save_render
  end

  def update
    check_params
    @user = find_user_by_id
    @user.update(params[:user])
    save_render
  end

  def destroy
    @user = find_user_by_id
    @user.mark_as_deleted
    render_data
  rescue => @error
    raise ActiveRecord::RecordInvalid, t('admin.users.destroy.error', error: @error.message)
  end

  def restore
    @users_scope = :deleted
    @user = find_user_by_id
    @user.restore
    render_data
  rescue => @error
    raise ActiveRecord::RecordInvalid, t('admin.users.restore.error', error: @error.message)
  end

  private

  def render_response
    if @error.nil?
      render_data
    else
      raise ActiveRecord::RecordNotSaved, @message
    end
  end

  def save_render
    if @user.save
      render_data
    else
      raise ActiveRecord::RecordNotSaved, @user.errors.messages
    end
  rescue => error
    raise ActiveRecord::RecordNotSaved, error.message
  end

  def render_data
    data = {}
    # Any better way to achieve this? Nested serializers don't seam to be possible..?
    data[:user] = {
      id: @user.id,
      first_name: @user.first_name,
      last_name: @user.last_name,
      email: @user.email,
      phone: @user.phone,
      settings_attributes: {
        profile: @user.settings[:profile],
        notify: @user.settings[:notify],
        messages: @user.settings[:messages]
      }
    }
    data[:user][:ordergroupid] = @user.ordergroup ? @user.ordergroup.id : nil
    if @user.deleted_at
      data[:user][:deleted_at] = @user.deleted_at
    end
    render status: :ok, json: data
  end

  def check_params
    # we do this for checking settings attributes. Any better way? Better in model?
    # note: this is NOT checked anywhere else!!!???
    if params[:user].key?(:settings_attributes)
      params[:user][:settings_attributes].each do |k1, v1|
        unless %w[profile notify].include?(k1)
          raise ActiveRecord::RecordNotSaved, param_not_allowed_message(k1, 'settings_attributes')
        end

        v1.each do |k2, v2|
          case k1
          when "profile"
            unless %w[language phone_is_public email_is_public].include?(k2)
              raise ActiveRecord::RecordNotSaved, param_not_allowed_message(k2, k1)
            end
          when "notify"
            unless %w[order_finished order_received negative_balance upcoming_tasks].include?(k2)
              raise ActiveRecord::RecordNotSaved, param_not_allowed_message(k2, k1)
            end
          end

          unless [true, false, '0', '1', 0, 1].include?(v2)
            raise ActiveRecord::RecordNotSaved, param_not_allowed_message(v2, k2)
          end

          case v2
          when "1", 1
            params[:user][:settings_attributes][k1][k2] = true
          when "0", 0
            params[:user][:settings_attributes][k1][k2] = false
          end
        end
      end
    end
  end

  def param_not_allowed_message(a, b)
    # translate it?
    "'#{a}' not allowed in '#{b}'"
  end

  def find_user_by_id
    scope.find(params.require(:id))
  end

  def scope
    if (@users_scope == :deleted) || params[:show_deleted]
      User.deleted
    elsif @users_scope == :all
      User
    else
      User.undeleted
    end
  end
end
