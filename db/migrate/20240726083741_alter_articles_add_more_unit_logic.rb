class AlterArticlesAddMoreUnitLogic < ActiveRecord::Migration[5.2]
  def up
    change_table :article_versions do |t|
      t.column :supplier_order_unit, :string, length: 3
      t.column :price_unit, :string, length: 3
      t.column :billing_unit, :string, length: 3
      t.column :group_order_unit, :string, length: 3
      t.column :group_order_granularity, :decimal, precision: 8, scale: 3, null: false, default: 1
      t.column :minimum_order_quantity, :float
      t.change :price, :decimal, precision: 11, scale: 6, null: false, comment: 'stored in `article_versions.supplier_order_unit`'
      t.change :unit, :string, null: true, default: nil
    end

    create_table :article_unit_ratios do |t|
      t.references :article_version, null: false

      t.column :sort, :integer, null: false, index: true
      t.column :quantity, :decimal, precision: 38, scale: 3, null: false
      t.column :unit, :string, length: 3
    end

    article_versions = select_all('SELECT id, unit, unit_quantity, price FROM article_versions WHERE unit_quantity > 1 AND NOT unit IS NULL')
    article_versions.each do |article_version|
      insert(%{
        INSERT INTO article_unit_ratios (article_version_id, sort, quantity, unit)
        VALUES (
          #{quote article_version['id']},
          #{quote 1},
          #{quote article_version['unit_quantity']},
          #{quote 'XPP'}
        )
      })

      compound_unit = "#{article_version['unit_quantity']}x#{article_version['unit']}"
      update(%(
        UPDATE article_versions
        SET unit = #{quote compound_unit},
          group_order_granularity = #{quote 1},
          group_order_unit = #{quote 'XPP'},
          price = #{quote article_version['price'].to_f * article_version['unit_quantity']},
          price_unit = #{quote 'XPP'},
          billing_unit = #{quote 'XPP'}
        WHERE article_versions.id = #{quote article_version['id']}
      ))
    end

    change_table :article_versions do |t|
      t.remove :unit_quantity
    end

    change_table :order_articles do |t|
      t.change :quantity, :decimal, precision: 8, scale: 3, null: false, comment: 'stored in `article_versions.group_order_unit`'
      t.change :tolerance, :decimal, precision: 8, scale: 3, null: false, comment: 'stored in `article_versions.group_order_unit`'
      t.change :units_to_order, :decimal, precision: 11, scale: 6, null: false, comment: 'stored in `article_versions.supplier_order_unit`'
      t.change :units_billed, :decimal, precision: 11, scale: 6, null: true, comment: 'stored in `article_versions.supplier_order_unit`'
      t.change :units_received, :decimal, precision: 11, scale: 6, null: true, comment: 'stored in `article_versions.supplier_order_unit`'
    end

    change_table :group_order_articles do |t|
      t.change :quantity, :decimal, precision: 8, scale: 3, null: false
      t.change :tolerance, :decimal, precision: 8, scale: 3, null: false
    end

    change_table :group_order_article_quantities do |t|
      t.change :quantity, :decimal, precision: 8, scale: 3, null: false
      t.change :tolerance, :decimal, precision: 8, scale: 3, null: false
    end
  end

  def down
    change_table :article_versions do |t|
      t.remove :supplier_order_unit
      t.remove :price_unit
      t.remove :billing_unit
      t.remove :group_order_unit
      t.remove :group_order_granularity
      t.remove :minimum_order_quantity
      t.column :unit_quantity, :integer, null: false
      t.change :price, :decimal, precision: 8, scale: 2, null: false, comment: ''
      t.change :unit, :string, null: true, default: ''
    end

    article_unit_ratios = select_all('SELECT article_version_id, quantity FROM article_unit_ratios WHERE sort=1')
    article_unit_ratios.each do |article_unit_ratio|
      update(%(
        UPDATE article_versions
        SET unit_quantity = #{quote article_unit_ratio['quantity']}
        WHERE id = #{quote article_unit_ratio['article_version_id']}
      ))
    end

    drop_table :article_unit_ratios

    change_table :order_articles do |t|
      t.change :quantity, :integer, null: false, comment: nil
      t.change :tolerance, :integer, null: false, comment: nil
      t.change :units_to_order, :integer, null: false, comment: nil
      t.change :units_billed, :decimal, precision: 8, scale: 3, null: true, comment: nil
      t.change :units_received, :decimal, precision: 8, scale: 3, null: true, comment: nil
    end

    change_table :group_order_articles do |t|
      t.change :quantity, :integer, null: false
      t.change :tolerance, :integer, null: false
    end

    change_table :group_order_article_quantities do |t|
      t.change :quantity, :integer, null: false
      t.change :tolerance, :integer, null: false
    end
  end
end
