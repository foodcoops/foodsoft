class CreateStockEvents < ActiveRecord::Migration[4.2]
  class StockEvent < ActiveRecord::Base; end
  class StockTaking < ActiveRecord::Base; end

  def change
    rename_table :deliveries, :stock_events
    rename_column :stock_changes, :delivery_id, :stock_event_id
    add_column :stock_events, :type, :string, default: 'Delivery', null: false

    reversible do |dir|
      dir.up do
        change_column_default :stock_events, :type, nil

        stock_event_max = StockEvent.maximum(:id) || 0
        stock_taking_min = StockTaking.minimum(:id) || 0
        diff = [stock_event_max + 1 - stock_taking_min, 0].max

        execute "UPDATE stock_changes SET stock_event_id = stock_taking_id + #{diff}
          WHERE stock_taking_id IS NOT NULL"
        execute "INSERT INTO stock_events (type, id, date, note, created_at)
          SELECT 'StockTaking', id + #{diff}, date, note, created_at FROM stock_takings"

        remove_column :stock_changes, :stock_taking_id
        drop_table :stock_takings
      end

      dir.down do
        create_table :stock_takings do |t|
          t.date :date
          t.text :note
          t.datetime :created_at
        end
        add_column :stock_changes, :stock_taking_id, :integer

        execute "INSERT INTO stock_takings (id, date, note, created_at)
          SELECT id, date, note, created_at FROM stock_events WHERE type = 'StockTaking'"
        execute "DELETE FROM stock_events WHERE type = 'StockTaking'"
        execute "UPDATE stock_changes SET stock_taking_id = stock_event_id, stock_event_id = NULL
          WHERE stock_event_id IN (SELECT id FROM stock_takings)"
      end
    end
  end
end
