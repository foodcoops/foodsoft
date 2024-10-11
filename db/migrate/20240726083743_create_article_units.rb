class CreateArticleUnits < ActiveRecord::Migration[5.2]
  def up
    create_table :article_units, id: false do |t|
      t.string :unit, length: 3, null: false

      t.timestamps
    end

    add_index :article_units, :unit, unique: true

    unit_codes = ArticleUnitsLib::DEFAULT_PIECE_UNIT_CODES + ArticleUnitsLib::DEFAULT_METRIC_SCALAR_UNIT_CODES

    unit_codes += ArticleUnitsLib::DEFAULT_IMPERIAL_SCALAR_UNIT_CODES if imperial_plain_text_units_exist?

    unit_codes.each do |unit_code|
      insert(%{
        INSERT INTO article_units (unit, created_at, updated_at)
        VALUES (
          #{quote unit_code},
          NOW(),
          NOW()
        )
      })
    end
  end

  def down
    drop_table :article_units
  end

  protected

  def imperial_plain_text_units_exist?
    plain_text_units = select_all('SELECT DISTINCT unit FROM article_versions').pluck('unit')
    plain_text_units.any? { |plain_text_unit| /(?:\s|[0-9])+(?:oz|lb)\s*$/.match(plain_text_unit) }
  end
end
