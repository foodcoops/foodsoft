class PollsController < ApplicationController
  before_action -> { require_plugin_enabled FoodsoftPolls }

  def index
    @polls = Poll.page(params[:page]).per(@per_page).order(created_at: :desc)
  end

  def show
    @poll = Poll.find(params[:id])
  end

  def new
    @poll = Poll.new
  end

  def create
    @poll = Poll.new(poll_params)
    @poll.created_by = current_user

    if @poll.save
      redirect_to @poll, notice: t('.notice')
    else
      render action: 'edit'
    end
  end

  def edit
    @poll = Poll.find(params[:id])

    if user_has_no_right
      redirect_to polls_path, alert: t('.no_right')
    end
  end

  def update
    @poll = Poll.find(params[:id])

    if user_has_no_right
      redirect_to polls_path, alert: t('.no_right')
    elsif @poll.update(poll_params)
      redirect_to @poll, notice: t('.notice')
    else
      render action: 'edit'
    end
  end

  def destroy
    @poll = Poll.find(params[:id])

    if user_has_no_right
      redirect_to polls_path, alert: t('.no_right')
    else
      @poll.destroy
      redirect_to polls_path, notice: t('.notice')
    end
  rescue => error
    redirect_to polls_path, alert: t('.error', error: error.message)
  end

  def vote
    @poll = Poll.find(params[:id])

    if @poll.one_vote_per_ordergroup
      ordergroup = current_user.ordergroup
      return redirect_to polls_path, alert: t('.no_ordergroup') unless ordergroup

      attributes = { ordergroup: ordergroup }
    else
      attributes = { user: current_user }
    end

    redirect_to @poll, alert: t('.no_right') unless @poll.user_can_vote?(current_user)

    @poll_vote = @poll.poll_votes.where(attributes).first_or_initialize

    if request.post?
      @poll_vote.update!(note: params[:note], user: current_user)

      if @poll.single_select?
        choices = {}
        choice = params[:choice]
        choices[choice] = '1' if choice
      else
        choices = params[:choices].try(:to_h) || {}
      end

      @poll_vote.poll_choices = choices.map do |choice, value|
        poll_choice = @poll_vote.poll_choices.where(choice: choice).first_or_initialize
        poll_choice.update!(value: value)
        poll_choice
      end

      redirect_to @poll
    end
  end

  private

  def user_has_no_right
    @poll.created_by != current_user && !current_user.role_admin?
  end

  def poll_params
    params
      .require(:poll)
      .permit(:name, :starts_date_value, :starts_time_value, :ends_date_value,
              :ends_time_value, :description, :one_vote_per_ordergroup, :voting_method,
              :multi_select_count, :min_points, :max_points, choices: [],
                                                             required_ordergroup_custom_fields: [], required_user_custom_fields: [])
  end
end
