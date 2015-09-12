class RenameOrderStates < ActiveRecord::Migration
  def up
    exchange
    Order.where(state: 'open').update_all(state: 'opened')
    change_column_default :orders, :state, 'opened'
  end

  def down
    change_column_default :orders, :state, 'open'
    Order.where(state: 'opened').update_all(state: 'open')
    exchange
  end

  private

  # Exchange finished and close states. Not idempotent, but equal for up and down :)
  def exchange
    Order.transaction do
      Order.where(state: 'finished').update_all(state: '_closed')
      Order.where(state: 'closed').update_all(state: 'finished')
      Order.where(state: '_closed').update_all(state: 'closed')
    end
  end
end
