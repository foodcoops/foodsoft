class MessageThreadsController < ApplicationController
  before_action -> { require_plugin_enabled FoodsoftMessages }

  def index
    @groups = Group.order(:name)
    group_map = @groups.index_by(&:id)  # { 1 => <Group id:1>, 2 => <Group id:2>, ... }
    group_ids = @groups.map(&:id)

    # Fetch all threads in one query
    all_threads = Message.readable_for(current_user)
                         .threads
                         .where(group_id: [nil] + group_ids)
                         .order(group_id: :asc, created_at: :desc)

    # Group by group_id and limit per group to 5
    @threads_by_group = all_threads
    .group_by(&:group_id)
    .transform_values do |threads|
      group_id = threads.first&.group_id
      {
        group: group_map[group_id],
        threads: threads.first(5),             # limited threads for view
        total_count: threads.size,
      }
    end

    all_threads_to_preload = @threads_by_group.values.flat_map { |h| h[:threads] }

  # Only call preloader if there are threads
    unless all_threads_to_preload.empty?
      ActiveRecord::Associations::Preloader.new(
        records: all_threads_to_preload,
        associations: [:sender, :message_recipients, { last_reply: :sender }]
      ).call
    end

  end

  def show
    @group = Group.find_by_id(params[:id])
    @message_threads = Message.readable_for(current_user).threads.where(group: @group).page(params[:page]).per(@per_page).order(created_at: :desc)
  end
end
