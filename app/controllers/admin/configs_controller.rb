class Admin::ConfigsController < Admin::BaseController

  before_action :get_tabs, only: [:show, :list]

  def show
    @current_tab = @tabs.include?(params[:tab]) ? params[:tab] : @tabs.first
    @cfg = FoodsoftConfig
  end

  def list
    @current_tab = 'list'
    @cfg = FoodsoftConfig
    @dfl = FoodsoftConfig.config
    @keys = FoodsoftConfig.keys.select {|k| FoodsoftConfig.allowed_key?(k)}.sort
  end

  def update
    parse_recurring_selects! params[:config][:order_schedule]
    ActiveRecord::Base.transaction do
      # TODO support nested configuration keys
      params[:config].each do |key, val|
        FoodsoftConfig[key] = val
      end
    end
    flash[:notice] = I18n.t('admin.configs.update.notice')
    redirect_to action: 'show'
  end

  protected

  # Set configuration tab names as `@tabs`
  def get_tabs
    @tabs = %w(foodcoop payment tasks messages layout language others)
    # allow engines to modify this list
    engines = Rails::Engine.subclasses.map(&:instance).select { |e| e.respond_to?(:configuration) }
    engines.each { |e| e.configuration(@tabs, self) }
    @tabs.uniq!
  end

  # turn recurring rules into something palatable
  def parse_recurring_selects!(config)
    if config
      for k in [:pickup, :boxfill, :ends] do
        if config[k]
          # allow clearing it using dummy value '{}' ('' would break recurring_select)
          if config[k][:recurr].present? && config[k][:recurr] != '{}'
            config[k][:recurr] = ActiveSupport::JSON.decode(config[k][:recurr])
            config[k][:recurr] = FoodsoftDateUtil.rule_from(config[k][:recurr]).to_ical if config[k][:recurr]
          else
            config[k] = nil
          end
        end
      end
    end
  end

end
