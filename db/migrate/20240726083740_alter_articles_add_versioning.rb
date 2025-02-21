class AlterArticlesAddVersioning < ActiveRecord::Migration[5.2]
  def up
    rename_table :article_prices, :article_versions
    rename_column :order_articles, :article_price_id, :article_version_id

    change_table :article_versions do |t|
      t.string :name, default: '', null: false
      t.integer :article_category_id, default: 0, null: false
      t.string :unit, default: ''
      t.string :note
      t.boolean :availability, default: true, null: false
      t.string :manufacturer
      t.string :origin
      t.string :order_number
      t.datetime :updated_at
    end

    # copy all article fields into article_versions
    articles = select_all('SELECT article_versions.id AS article_version_id, articles.* FROM article_versions JOIN articles ON articles.id = article_versions.article_id')
    articles.each do |article|
      update(%(
        UPDATE article_versions SET
          name = #{quote article['name']},
          article_category_id = #{quote article['article_category_id']},
          unit = #{quote article['unit']},
          note = #{quote article['note']},
          availability = #{quote article['availability']},
          manufacturer = #{quote article['manufacturer']},
          origin = #{quote article['origin']},
          order_number = #{quote article['order_number']},
          updated_at = #{quote article['updated_at']}
        WHERE id = #{quote article['article_version_id']}
      ))
    end

    remove_index :articles, %i[name supplier_id]

    # drop article columns (now superfluous as they exist in article_versions):
    change_table :articles do |t|
      t.remove :name
      t.remove :article_category_id
      t.remove :unit
      t.remove :note
      t.remove :availability
      t.remove :manufacturer
      t.remove :origin
      t.remove :order_number
      t.remove :updated_at
      t.remove :price
      t.remove :tax
      t.remove :deposit
      t.remove :unit_quantity
    end

    # remove order_articles' reference to articles (reference now always goes through article_versions):
    articles = select_all(%(
      SELECT articles.id AS article_id, article_versions.id AS article_version_id
      FROM articles
      JOIN article_versions ON article_versions.article_id = articles.id
      JOIN order_articles ON order_articles.article_id = articles.id
      WHERE order_articles.article_version_id IS NULL
      GROUP BY article_versions.article_id
      ORDER BY article_versions.created_at DESC
    ))

    articles.each do |article|
      update(%(
        UPDATE order_articles
        SET article_version_id = #{quote article['article_version_id']}
        WHERE order_articles.article_version_id IS NULL
          AND order_articles.article_id = #{quote article['article_id']}
      ))
    end

    # Remove orphaned order articles (db inconsistencies due to lack of foreign key constraints):
    delete('DELETE FROM order_articles WHERE order_articles.article_version_id IS NULL')

    # De-duplicate article version (db inconsistencies due to lack of unique key for created_at and article_id):
    duplicate_article_versions = select_all(%{
      SELECT article_id, created_at
      FROM article_versions
      GROUP BY article_id, created_at
      HAVING COUNT(*) > 1
    })

    duplicate_article_versions.each do |duplicate_article_version|
      article_versions = select_all(%(
        SELECT id
        FROM article_versions
        WHERE article_id = #{quote duplicate_article_version['article_id']}
          AND created_at = #{quote duplicate_article_version['created_at']}
      ))

      latest_version = article_versions.last
      article_versions[0..-2].each do |obsolete_version|
        update("UPDATE order_articles SET article_version_id = #{quote latest_version['id']} WHERE article_version_id = #{quote obsolete_version['id']}")
        delete("DELETE FROM article_versions WHERE id = #{quote obsolete_version['id']}")
      end
    end

    remove_index :order_articles, %i[order_id article_id]
    remove_column :order_articles, :article_id
    change_column_null :order_articles, :article_version_id, false
    add_index :order_articles, %i[order_id article_version_id], unique: true
    add_index :order_articles, :article_version_id
    remove_index :article_versions, :article_id
    add_index :article_versions, %i[article_id created_at], unique: true
    add_index :article_versions, [:article_category_id]
  end

  def down
    rename_table :article_versions, :article_prices
    rename_column :order_articles, :article_version_id, :article_price_id

    remove_index :order_articles, %i[order_id article_price_id]
    remove_index :order_articles, :article_price_id
    remove_index :article_prices, %i[article_id created_at]
    remove_index :article_prices, [:article_category_id]

    add_column :order_articles, :article_id, :integer
    change_column_null :order_articles, :article_price_id, true

    change_table :articles do |t|
      t.string :name, default: '', null: false
      t.integer :article_category_id, default: 0, null: false
      t.string :unit, default: ''
      t.string :note
      t.boolean :availability, default: true, null: false
      t.string :manufacturer
      t.string :origin
      t.string :order_number
      t.datetime :updated_at
      t.decimal :price, precision: 8, scale: 2
      t.float :tax
      t.decimal :deposit, precision: 8, scale: 2, default: '0.0'
      t.integer :unit_quantity, null: false, default: 0
    end

    article_prices = select_all(%{
      SELECT article_prices.*
      FROM article_prices
      JOIN (
        SELECT article_id, MAX(created_at) AS max_created_at
        FROM article_prices
        GROUP BY article_id
      ) AS latest_article_prices
      ON latest_article_prices.article_id = article_prices.article_id
        AND latest_article_prices.max_created_at = article_prices.created_at
    })
    article_prices.each do |article_price|
      update(%(
        UPDATE articles SET
          name = #{quote article_price['name']},
          article_category_id = #{quote article_price['article_category_id']},
          unit = #{quote article_price['unit']},
          note = #{quote article_price['note']},
          availability = #{quote article_price['availability']},
          manufacturer = #{quote article_price['manufacturer']},
          origin = #{quote article_price['origin']},
          order_number = #{quote article_price['order_number']},
          updated_at = #{quote article_price['updated_at']},
          type = #{quote article_price['type']},
          price = #{quote article_price['price']},
          tax = #{quote article_price['tax']},
          deposit = #{quote article_price['deposit']},
          unit_quantity = #{quote article_price['unit_quantity']}
        WHERE id = #{quote article_price['article_id']}
      ))
    end

    order_articles = select_all(%(
      SELECT order_articles.id, article_prices.article_id
      FROM order_articles
      JOIN article_prices ON article_prices.id = order_articles.article_price_id
    ))

    order_articles.each do |order_article|
      update(%(
        UPDATE order_articles
        SET article_id = #{quote order_article['article_id']}
        WHERE id = #{quote order_article['id']}
      ))
    end

    update(%{
      UPDATE order_articles
      SET article_price_id = NULL
      WHERE order_id IN (SELECT id FROM orders WHERE state = #{quote 'open'})
    })

    change_table :article_prices do |t|
      t.remove :name
      t.remove :article_category_id
      t.remove :unit
      t.remove :note
      t.remove :availability
      t.remove :manufacturer
      t.remove :origin
      t.remove :order_number
      t.remove :updated_at
    end

    change_column_default :articles, :unit_quantity, nil
    change_column_null :order_articles, :article_id, false
    add_index :order_articles, %i[order_id article_id], unique: true
    add_index :article_prices, :article_id
    add_index :articles, %i[name supplier_id]
  end

  protected

  # We cannot use quote out of context (as it wouldn't relate to the current DB syntax),
  # but using Article's db connection by default should be fine
  def quote(value)
    Article.connection.quote(value)
  end
end
