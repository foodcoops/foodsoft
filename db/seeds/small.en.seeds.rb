require_relative 'seed_helper'

## Financial transaction classes

FinancialTransactionClass.create!(id: 1, name: 'Standard')
FinancialTransactionClass.create!(id: 2, name: 'Foodsoft')

## Article units

unit_codes = ArticleUnitsLib::DEFAULT_PIECE_UNIT_CODES + ArticleUnitsLib::DEFAULT_METRIC_SCALAR_UNIT_CODES
unit_codes.each { |unit_code| ArticleUnit.create!(unit: unit_code) }

## Suppliers & articles

SupplierCategory.create!(id: 1, name: 'Other', financial_transaction_class_id: 1)

Supplier.create!([
                   { id: 1, name: 'Beautiful bakery', supplier_category_id: 1,
                     address: 'Smallstreet 1, Cookilage', phone: '0123456789', email: 'info@bbakery.test', min_order_quantity: '100' },
                   { id: 2, name: 'Chocolatiers', supplier_category_id: 1,
                     address: 'Multatuliroad 1, Amsterdam', phone: '0123456789', email: 'info@chocolatiers.test', url: 'http://www.chocolatiers.test/', contact_person: 'Max Pure', delivery_days: 'Tue, Fr (Amsterdam)' },
                   { id: 3, name: 'Cheesemaker', supplier_category_id: 1,
                     address: 'Cheesestreet 5, London', phone: '0123456789', url: 'http://www.cheesemaker.test/' },
                   { id: 4, name: 'The Nuthome', supplier_category_id: 1,
                     address: 'Alexanderplatz, Berlin', phone: '0123456789', email: 'info@thenuthome.test', url: 'http://www.thenuthome.test/', note: 'delivery in Berlin; €9 delivery costs for orders under €123' },
                   { id: 5, name: 'Farmer John', supplier_category_id: 1, address: 'Smallstreet 1, Cookilage',
                     phone: '0123456789', email: 'info@john.com', min_order_quantity: '100', unit_migration_completed: Time.now },
                   { id: 6, name: 'Unit migration test', supplier_category_id: 1, address: 'Smallstreet 2, Cookilage',
                     phone: '0123456789', email: 'info@bbakery.test', min_order_quantity: '100', unit_migration_completed: nil }
                 ])

ArticleCategory.create!(id: 1, name: 'Other', description: 'other, misc, unknown')
ArticleCategory.create!(id: 2, name: 'Fruit')
ArticleCategory.create!(id: 3, name: 'Vegetables')
ArticleCategory.create!(id: 4, name: 'Potatoes & onions')
ArticleCategory.create!(id: 5, name: 'Bread & Bakery')
ArticleCategory.create!(id: 6, name: 'Drinks', description: 'juice, fruit juice, vegetable juice, soda')
ArticleCategory.create!(id: 7, name: 'Herbs & Spices')
ArticleCategory.create!(id: 8, name: 'Milk & products',
                        description: 'milk, butter, cream, yoghurt, cheese, eggs, milk substitutes')
ArticleCategory.create!(id: 9, name: 'Fish & Sea')
ArticleCategory.create!(id: 10, name: 'Meat')
ArticleCategory.create!(id: 11, name: 'Oils & Fats')
ArticleCategory.create!(id: 12, name: 'Grains & Legumes')
ArticleCategory.create!(id: 13, name: 'Nuts & Seeds')
ArticleCategory.create!(id: 14, name: 'Sugar & Sweets')

### Beautiful bakery

[
  { name: 'Brown whole', price: 0.22E1 },
  { name: 'Brown half', price: 0.11E1 },
  { name: 'Brown sesame whole', price: 0.22E1 },
  { name: 'Brown sesame half', price: 0.11E1 },
  { name: 'Light wheat whole', price: 0.22E1 },
  { name: 'Light wheat half', price: 0.11E1 },
  { name: 'Bread with sunflower seeds whole', price: 0.33E1 },
  { name: 'Bread with sunflower seeds  half', price: 0.11E1 },
  { name: 'Bread with walnuts whole', price: 0.33E1 },
  { name: 'Bread with walnuts half', price: 0.11E1 },
  { name: 'Kennemerlandbread whole', price: 0.33E1 },
  { name: 'Kennemerlandbread half', price: 0.11E1 },
  { name: 'Maize bread whole', price: 0.33E1 },
  { name: 'Maize bread  half', price: 0.11E1 },
  { name: 'Oberlander 1200 gram whole', price: 0.33E1 },
  { name: 'Oberlander 1200 gram half', price: 0.11E1 },
  { name: 'Oberlander 900 gram whole', price: 0.33E1 },
  { name: 'Oberlander 900 gram half', price: 0.11E1 },
  { name: 'Speltbread whole', price: 0.33E1 },
  { name: 'Speltbread half', price: 0.11E1 },
  { name: 'Country bread 900gram whole', price: 0.33E1 },
  { name: 'Country bread 900gram half', price: 0.11E1 },
  { name: 'White  whole', price: 0.33E1 },
  { name: 'White  half', price: 0.11E1 },
  { name: 'White with poppy seeds whole', price: 0.33E1 },
  { name: 'White with poppy seeds half', price: 0.11E1 },
  { name: 'Fig bread whole', price: 0.33E1 },
  { name: 'Fig bread half', price: 0.11E1 },
  { name: 'Beer-based bread whole', price: 0.33E1 },
  { name: 'Beer-based bread half', price: 0.22E1 },
  { name: 'Raisin bun', price: 0.99E0 },
  { name: 'Muesli bun', price: 0.11E1 },
  { name: 'Brioche', price: 0.99E0 },
  { name: 'Brown croissant', price: 0.11E1 },
  { name: 'Croissants', price: 0.11E1 },
  { name: 'Cheese croissants', price: 0.11E1 },
  { name: 'Chocolatecroissants', price: 0.11E1 },
  { name: 'Soepstengels white', price: 0.11E1 },
  { name: 'Soepstengels whole grain', price: 0.99E0 },
  { name: 'Pumpkin-seed buns', price: 0.88E0 },
  { name: 'White buns', price: 0.66E0 },
  { name: 'Brown buns', price: 0.66E0 },
  { name: 'Tomato-feta bread', price: 0.11E1 }

].each do |a|
  Article.create!({ supplier_id: 1,
                    quantity: 0 })
         .article_versions.create({ name: a[:name],
                                    note: 'organic',
                                    availability: true,
                                    manufacturer: 'The Baker',
                                    article_category_id: 5,
                                    unit: nil,
                                    price: a[:price],
                                    tax: 6.0,
                                    deposit: '0.0',
                                    supplier_order_unit: 'XPP',
                                    price_unit: 'XPP',
                                    billing_unit: 'XPP',
                                    group_order_unit: 'XPP' })
end

### Chocolatiers

[
  { name: 'Chocolate Bar Milk (37%)', price: '0.22E1', quantity: 90 },
  { name: 'Chocolate Bar Pure (68%)', price: '0.22E1', quantity: 90 },
  { name: 'Chocolate Bar Milk (40%)', price: '0.22E1', quantity: 90 },
  { name: 'Chocolate Bar Pure (75%)', price: '0.22E1', quantity: 90 },
  { name: 'Chocolate Bar Swan Pure (75%)', price: '0.66E1', quantity: 120 },
  { name: 'Cacao nibs', price: '0.10E2', quantity: 1 }
].each do |a|
  Article.create!({ supplier_id: 2,
                    quantity: 0 })
         .article_versions.create({ name: a[:name],
                                    note: 'organic',
                                    availability: true,
                                    manufacturer: 'Chocolatemakers',
                                    article_category_id: 14,
                                    unit: nil,
                                    price: a[:price],
                                    tax: 6.0,
                                    deposit: '0.0',
                                    supplier_order_unit: 'XPP',
                                    price_unit: 'XPP',
                                    billing_unit: 'XPP',
                                    group_order_unit: 'XPP',
                                    article_unit_ratios: [ArticleUnitRatio.new({ sort: 1, quantity: a[:quantity], unit: 'KGM' })] })
end

### Cheesemaker

[
  { name: 'Cheese Cow-young', price: 0.88E1, quantity: 8 },
  { name: 'Cheese cow- young matured', price: 0.99E1, quantity: 8 },
  { name: 'Cheese cow- matured', price: 0.11E2, quantity: 12 },
  { name: 'Cheese cow- extra matured', price: 0.12E2, quantity: 8 },
  { name: 'cheese Cow- old', price: 0.11E2, quantity: 8 },
  { name: 'cheese cow -very old', price: 0.12E2, quantity: 8 },
  { name: 'Cheese Cow-nettle young', price: 0.99E1, quantity: 8 },
  { name: 'Cheese cow- nettle young matured', price: 0.1075E2, quantity: 8 },
  { name: 'Cheese cow- nettle matured', price: 0.11E2, quantity: 8 },
  { name: 'Cheese Cow-cumin young', price: 0.99E1, quantity: 8 },
  { name: 'Cheese cow- cumin young matured', price: 0.1075E2, quantity: 8 },
  { name: 'Cheese cow- cumin matured', price: 0.11E2, quantity: 8 }
].each do |a|
  Article.create!({ supplier_id: 3,
                    quantity: 0 })
         .article_versions.create({ name: a[:name],
                                    note: 'organic',
                                    origin: 'NL',
                                    availability: true,
                                    manufacturer: 'Cheesefarm',
                                    article_category_id: 8,
                                    unit: nil,
                                    price: a[:price],
                                    tax: 6.0,
                                    deposit: '0.0',
                                    supplier_order_unit: 'XPP',
                                    price_unit: 'XPP',
                                    billing_unit: 'XPP',
                                    group_order_unit: 'XPP',
                                    article_unit_ratios: [ArticleUnitRatio.new({ sort: 1, quantity: a[:quantity], unit: 'KGM' })] })
end

### The Nuthome
[
  { order_number: ':b936051', name: 'Cashew nuts', price: 0.4444E2, quantity: 22 },
  { order_number: ':9e3f85b', name: 'White hazelnuts',  price: 0.3333E2,  quantity: 10 },
  { order_number: ':d278041', name: 'Brown hazelnuts',  price: 0.1111E2,  quantity: 10 },
  { order_number: ':0b51a8d', name: 'Spanish almond brown', price: 0.999E1, quantity: 10 },
  { order_number: ':01e59e3', name: 'Brazil nuts (organic)', price: 0.6666E2, quantity: 20 },
  { order_number: ':7ff8587', name: 'Organic light walnut halves', price: 0.333E1, quantity: 10 },
  { order_number: ':aa88d9f', name: 'Pine nuts', price: 0.888E1, quantity: 25 },
  { order_number: ':e63069b', name: 'Pumpkin', price: 0.1111E2,  quantity: 25 },
  { order_number: ':0428388', name: 'Sunflower seeds (organic)', price: 0.999E1, quantity: 25 },
  { order_number: ':a8f0734', name: 'Spanish almond white', price: 0.66666E3, quantity: 10 },
  { order_number: ':1d26958', name: 'Cashews', price: 0.6666E2, quantity: 1 },
  { order_number: ':31439e2', name: 'Blanched almonds', price: 0.333E1,  quantity: 1 },
  { order_number: ':9c49374', name: 'Natural almonds', price: 0.1111E2,  quantity: 1 },
  { order_number: ':92907d1', name: 'Walnut ELH halves', price: 0.4444E2,  quantity: 1 },
  { order_number: ':395640e', name: 'Walnut ELP pieces', price: 0.8888E2,  quantity: 1 },
  { order_number: ':710acbb', name: 'Brazil nuts', price: 0.8888E2, quantity: 1 },
  { order_number: ':bbaf40b', name: 'Macadamia Style 0', price: 0.3333E2, quantity: 1 },
  { order_number: ':7958183', name: 'Pecans', price: 0.55555E3, quantity: 1 },
  { order_number: ':50392a8', name: 'Natural hazelnuts', price: 0.6666E2,  quantity: 1 },
  { order_number: ':4fe6525', name: 'Blanched hazelnuts', price: 0.3333E2, quantity: 1 },
  { order_number: ':c051b22', name: 'Mixed nuts', price: 0.333E1, quantity: 1 },
  { order_number: ':f507577', name: 'Peanuts', price: 0.777E1, quantity: 1 },
  { order_number: ':ce563bb', name: 'Peanuts without skin (small)', price: 0.8888E2, quantity: 1 },
  { order_number: ':8232061', name: 'Medjool dates', price: 0.3333E2, quantity: 1 },
  { order_number: ':185084f', name: 'Turkish unsulphured apricots', price: 0.888E1, quantity: 1 },
  { order_number: ':2b2fb20', name: 'Turkish sulphured apricots', price: 0.1111E2, quantity: 1 },
  { order_number: ':82590b1', name: 'Spanish figs', price: 0.444E1,  quantity: 1 },
  { order_number: ':cabeeb6', name: 'Turkish figs', price: 0.555E1,  quantity: 1 },
  { order_number: ':2ac18b7', name: 'South African unsulphured apricots', price: 0.1111E2, quantity: 1 },
  { order_number: ':16bfa75', name: 'Blue raisins Flames', price: 0.1111E2, quantity: 1 },
  { order_number: ':1c59324', name: 'Yellow raisins', price: 0.2222E2, quantity: 1 },
  { order_number: ':c3fcd84', name: 'Red raisins', price: 0.1111E2, quantity: 1 },
  { order_number: ':921c168', name: 'Whole cranberries', price: 0.222E1, quantity: 1 },
  { order_number: ':902c67b', name: 'Dried apple pieces', price: 0.555E1,  quantity: 1 },
  { order_number: ':a847f91', name: 'Pitted dried plums', price: 0.222E1,  quantity: 1 },
  { order_number: ':535645f', name: 'Pumpkin seeds', price: 0.111E1, quantity: 1 },
  { order_number: ':4ab9a83', name: 'Sunflower seeds', price: 0.666E1, quantity: 1 },
  { order_number: ':04be223', name: 'Flaxseeds', price: 0.55E0, quantity: 1 },
  { order_number: ':ec5b2b9', name: 'Poppy seeds', price: 0.7777E2,  quantity: 1 },
  { order_number: ':0e5b0b8', name: 'Pine nuts medium China', price: 0.2222E2, quantity: 1 },
  { order_number: ':d52ee00', name: 'Goji berries', price: 0.888E1,  quantity: 1 },
  { order_number: ':5f46bd5', name: 'Mulberries', price: 0.5555E2, quantity: 1 },
  { order_number: ':c39165b', name: 'Shelled hemp seeds', price: 0.5555E2, quantity: 1 },
  { order_number: ':8d44fe7', name: 'Incaberries', price: 0.888E1, quantity: 1 },
  { order_number: ':9a95422', name: 'Blueberries', price: 0.2222E2,  quantity: 1 },
  { order_number: ':416d57b', name: 'Chia seeds', price: 0.55555E3,  quantity: 1 },
  { order_number: ':b3f65e4', name: 'Coconut rasp', price: 0.55E0, quantity: 1 }
].each do |a|
  Article.create!({ supplier_id: 4,
                    quantity: 0 })
         .article_versions.create({ name: a[:name],
                                    note: 'organic',
                                    availability: true,
                                    manufacturer: 'The Nuthome',
                                    order_number: a[:order_number],
                                    article_category_id: 13,
                                    unit: nil,
                                    price: a[:price],
                                    tax: 6.0,
                                    deposit: '0.0',
                                    supplier_order_unit: 'XPP',
                                    price_unit: 'XPP',
                                    billing_unit: 'XPP',
                                    group_order_unit: 'XPP',
                                    article_unit_ratios: [ArticleUnitRatio.new({ sort: 1, quantity: a[:quantity], unit: 'KGM' })] })
end

### Farmer John

Article.create!({ supplier_id: 5,
                  quantity: 0 }).article_versions.create({ name: 'Carrots', article_category_id: 3, unit: nil, price: 3, tax: 7.0,
                                                           deposit: '0.0', supplier_order_unit: 'KGM', price_unit: 'KGM', billing_unit: 'KGM', group_order_unit: 'KGM', group_order_granularity: 0.001 })
Article.create!({ supplier_id: 5,
                  quantity: 0 }).article_versions.create({ name: 'Pumpkin', article_category_id: 3, unit: nil, price: 1.5, tax: 7.0, deposit: '0.0', supplier_order_unit: 'XPP', price_unit: 'KGM', billing_unit: 'KGM', group_order_unit: 'XPP',
                                                           article_unit_ratios: [ArticleUnitRatio.new({ sort: 1, quantity: 1.3, unit: 'KGM' })] })
Article.create!({ supplier_id: 5,
                  quantity: 0 }).article_versions.create({ name: 'Bread', article_category_id: 5, unit: nil, price: 2.1, tax: 7.0, deposit: '0.0', supplier_order_unit: 'XPP', price_unit: 'KGM', billing_unit: 'KGM', group_order_unit: 'XPP', group_order_granularity: 0.5,
                                                           article_unit_ratios: [ArticleUnitRatio.new({ sort: 1, quantity: 700, unit: 'GRM' })] })
Article.create!({ supplier_id: 5,
                  quantity: 0 }).article_versions.create({ name: 'Bread rolls', article_category_id: 5, unit: nil, price: 1, tax: 7.0, deposit: '0.0', supplier_order_unit: 'XPP', price_unit: 'KGM', billing_unit: 'XPP', group_order_unit: 'XPP', minimum_order_quantity: 5,
                                                           article_unit_ratios: [ArticleUnitRatio.new({ sort: 1, quantity: 350, unit: 'GRM' })] })
Article.create!({ supplier_id: 5,
                  quantity: 0 }).article_versions.create({ name: 'Muesli', article_category_id: 13, unit: nil, price: 2.5, tax: 7.0, deposit: '0.0', supplier_order_unit: 'XPP', price_unit: 'XPP', billing_unit: 'XPP', group_order_unit: 'XPP',
                                                           article_unit_ratios: [ArticleUnitRatio.new({ sort: 1, quantity: 500, unit: 'GRM' })] })
Article.create!({ supplier_id: 5,
                  quantity: 0 }).article_versions.create({ name: 'Smoked tofu', article_category_id: 8, unit: nil, price: 2.4, tax: 7.0, deposit: '0.0', supplier_order_unit: 'XPP', price_unit: 'HGM', billing_unit: 'GRM', group_order_unit: 'XPP',
                                                           article_unit_ratios: [ArticleUnitRatio.new({ sort: 1, quantity: 160, unit: 'GRM' })] })
Article.create!({ supplier_id: 5,
                  quantity: 0 }).article_versions.create({ name: 'Beer', article_category_id: 6, unit: nil, price: 52, tax: 7.0, deposit: '0.0', supplier_order_unit: 'XCR', price_unit: 'XBO', billing_unit: 'XBO', group_order_unit: 'XBO',
                                                           article_unit_ratios: [ArticleUnitRatio.new({ sort: 1, quantity: 20, unit: 'XBO' }), ArticleUnitRatio.new({ sort: 2, quantity: 10, unit: 'LTR' })] })
Article.create!({ supplier_id: 5,
                  quantity: 0 }).article_versions.create({ name: 'Detergent', article_category_id: 1, unit: nil, price: 20, tax: 7.0, deposit: '0.0', supplier_order_unit: 'XPP', price_unit: 'LTR', billing_unit: 'LTR', group_order_unit: 'LTR', group_order_granularity: 0.001,
                                                           article_unit_ratios: [ArticleUnitRatio.new({ sort: 2, quantity: 20, unit: 'LTR' }), ArticleUnitRatio.new({ sort: 2, quantity: 25, unit: 'KGM' })] })
Article.create!({ supplier_id: 5,
                  quantity: 0 }).article_versions.create({ name: 'Rice', article_category_id: 12, unit: nil, price: 6.75, tax: 7.0, deposit: '0.0', supplier_order_unit: 'XPP', price_unit: 'KGM', billing_unit: 'KGM', group_order_unit: 'KGM', group_order_granularity: 0.05,
                                                           article_unit_ratios: [ArticleUnitRatio.new({ sort: 1, quantity: 25, unit: 'KGM' })] })
Article.create!({ supplier_id: 5,
                  quantity: 0 }).article_versions.create({ name: 'Potatoes', article_category_id: 3, unit: nil, price: 1.5, tax: 7.0,
                                                           deposit: '0.0', supplier_order_unit: 'KGM', price_unit: 'KGM', billing_unit: 'KGM', group_order_unit: 'GRM' })
Article.create!({ supplier_id: 5,
                  quantity: 0 }).article_versions.create({ name: 'Wheat', article_category_id: 12, unit: nil, price: 25, tax: 7.0, deposit: '0.0', supplier_order_unit: 'XPP', price_unit: 'KGM', billing_unit: 'KGM', group_order_unit: 'KGM', group_order_granularity: 0.05,
                                                           article_unit_ratios: [ArticleUnitRatio.new({ sort: 1, quantity: 25, unit: 'KGM' })] })
Article.create!({ supplier_id: 5,
                  quantity: 0 }).article_versions.create({ name: 'Oranges', article_category_id: 2, unit: nil, price: 36, tax: 7.0, deposit: '0.0', supplier_order_unit: 'XPP', price_unit: 'KGM', billing_unit: 'KGM', group_order_unit: 'KGM', group_order_granularity: 0.05,
                                                           article_unit_ratios: [ArticleUnitRatio.new({ sort: 1, quantity: 12, unit: 'KGM' })] })
Article.create!({ supplier_id: 5,
                  quantity: 0 }).article_versions.create({ name: 'Lentils', article_category_id: 12, unit: nil, price: 2.7, tax: 7.0, deposit: '0.0', supplier_order_unit: 'XPP', price_unit: 'KGM', billing_unit: 'KGM', group_order_unit: 'KGM', group_order_granularity: 0.05,
                                                           article_unit_ratios: [ArticleUnitRatio.new({ sort: 1, quantity: 500, unit: 'GRM' })] })
Article.create!({ supplier_id: 5,
                  quantity: 0 }).article_versions.create({ name: 'Oyster mushrooms', article_category_id: 3, unit: nil,
                                                           price: 3, tax: 7.0, deposit: '0.0', supplier_order_unit: 'KGM', price_unit: 'KGM', billing_unit: 'KGM', group_order_unit: 'KGM', group_order_granularity: 0.001, minimum_order_quantity: 1.2 })

### Unit migration test

Article.create!({ supplier_id: 6,
                  quantity: 0 }).article_versions.create({ name: 'Goat cheese', article_category_id: 8, unit: '250g', price: 3, tax: 7.0,
                                                           deposit: '0.0', supplier_order_unit: nil, price_unit: nil, billing_unit: nil, group_order_unit: nil, group_order_granularity: 1 })
Article.create!({ supplier_id: 6,
                  quantity: 0 }).article_versions.create({ name: 'Butter', article_category_id: 8, unit: '4x250g', price: 3, tax: 7.0, deposit: '0.0', supplier_order_unit: nil, price_unit: 'XPP', billing_unit: 'XPP', group_order_unit: 'XPP', group_order_granularity: 1,
                                                           article_unit_ratios: [ArticleUnitRatio.new({ sort: 1, quantity: 4, unit: 'XPP' })] })
Article.create!({ supplier_id: 6,
                  quantity: 0 }).article_versions.create({ name: 'Bread', article_category_id: 5, unit: 'pc', price: 3, tax: 7.0,
                                                           deposit: '0.0', supplier_order_unit: nil, price_unit: nil, billing_unit: nil, group_order_unit: nil, group_order_granularity: 1 })

## Members & groups

User.create!(id: 1, nick: 'admin', password: 'secret', first_name: 'Anton', last_name: 'Administrator',
             email: 'admin@foo.test', phone: '+4421486548', created_on: 'Wed, 15 Jan 2014 16:15:33 UTC +00:00')
User.create!(id: 2, nick: 'john', password: 'secret', first_name: 'John', last_name: 'Doe',
             email: 'john@doe.test', created_on: 'Sun, 19 Jan 2014 17:38:22 UTC +00:00')
User.create!(id: 3, nick: 'peter', password: 'secret', first_name: 'Peter', last_name: 'Peters',
             email: 'peter@peters.test', phone: '+4711235486811', created_on: 'Sat, 25 Jan 2014 20:20:36 UTC +00:00')
User.create!(id: 4, nick: 'jan', password: 'secret', first_name: 'Jan', last_name: 'Lou',
             email: 'jan@lou.test', created_on: 'Mon, 27 Jan 2014 16:22:14 UTC +00:00')
User.create!(id: 5, nick: 'mary', password: 'secret', first_name: 'Mary', last_name: 'Lou',
             email: 'marie@lou.test', created_on: 'Mon, 03 Feb 2014 11:47:17 UTC +00:00')
User.find_by_nick('mary').update(last_activity: 5.days.ago)

Workgroup.create!(id: 1, name: 'Administrators', description: 'System administrators.',
                  account_balance: 0.0, created_on: 'Wed, 15 Jan 2014 16:15:33 UTC +00:00', role_admin: true, role_suppliers: true, role_article_meta: true, role_finance: true, role_orders: true, next_weekly_tasks_number: 8, ignore_apple_restriction: false)
Workgroup.create!(id: 2, name: 'Finances', account_balance: 0.0,
                  created_on: 'Sun, 19 Jan 2014 17:40:03 UTC +00:00', role_admin: false, role_suppliers: false, role_article_meta: false, role_finance: true, role_orders: false, next_weekly_tasks_number: 8, ignore_apple_restriction: false)
Workgroup.create!(id: 3, name: 'Ordering', account_balance: 0.0,
                  created_on: 'Thu, 20 Feb 2014 14:44:47 UTC +00:00', role_admin: false, role_suppliers: false, role_article_meta: true, role_finance: false, role_orders: true, next_weekly_tasks_number: 8, ignore_apple_restriction: false)
Workgroup.create!(id: 4, name: 'Assortment', account_balance: 0.0,
                  created_on: 'Wed, 09 Apr 2014 12:24:55 UTC +00:00', role_admin: false, role_suppliers: true, role_article_meta: true, role_finance: false, role_orders: false, next_weekly_tasks_number: 8, ignore_apple_restriction: false)
Ordergroup.create!(id: 5, name: 'Admin Administrator', account_balance: 0.0,
                   created_on: 'Sat, 18 Jan 2014 00:38:48 UTC +00:00', role_admin: false, role_suppliers: false, role_article_meta: false, role_finance: false, role_orders: false, stats: { jobs_size: 0, orders_sum: 1021.74 }, next_weekly_tasks_number: 8, ignore_apple_restriction: true)
Ordergroup.create!(id: 6, name: "Pete's house", account_balance: -0.35E2,
                   created_on: 'Sat, 25 Jan 2014 20:20:37 UTC +00:00', role_admin: false, role_suppliers: false, role_article_meta: false, role_finance: false, role_orders: false, contact_person: 'Piet Pieterssen', stats: { jobs_size: 0, orders_sum: 60.96 }, next_weekly_tasks_number: 8, ignore_apple_restriction: false)
Ordergroup.create!(id: 7, name: 'Jan Klaassen', account_balance: -0.35E2,
                   created_on: 'Mon, 27 Jan 2014 16:22:14 UTC +00:00', role_admin: false, role_suppliers: false, role_article_meta: false, role_finance: false, role_orders: false, contact_person: 'Jan Klaassen', stats: { jobs_size: 0, orders_sum: 0 }, next_weekly_tasks_number: 8, ignore_apple_restriction: false)
Ordergroup.create!(id: 8, name: 'John Doe', account_balance: 0.90E2,
                   created_on: 'Wed, 09 Apr 2014 12:23:29 UTC +00:00', role_admin: false, role_suppliers: false, role_article_meta: false, role_finance: false, role_orders: false, contact_person: 'John Doe', stats: { jobs_size: 0, orders_sum: 0 }, next_weekly_tasks_number: 8, ignore_apple_restriction: false)

Membership.create!(group_id: 1, user_id: 1)
Membership.create!(group_id: 5, user_id: 1)
Membership.create!(group_id: 2, user_id: 2)
Membership.create!(group_id: 8, user_id: 2)
Membership.create!(group_id: 6, user_id: 3)
Membership.create!(group_id: 7, user_id: 4)
Membership.create!(group_id: 8, user_id: 4)
Membership.create!(group_id: 3, user_id: 4)
Membership.create!(group_id: 7, user_id: 5)
Membership.create!(group_id: 3, user_id: 5)
Membership.create!(group_id: 4, user_id: 5)

## Orders & OrderArticles

seed_order(supplier_id: 1, starts: 2.days.ago, ends: 5.days.from_now)
seed_order(supplier_id: 3, starts: 3.days.ago, ends: 5.days.from_now)
seed_order(supplier_id: 2, starts: 4.days.ago, ends: 4.days.from_now)
seed_order(supplier_id: 4, starts: 1.day.ago, ends: 10.days.from_now)
seed_order(supplier_id: 5, starts: 10.days.ago, ends: 1.day.from_now)

## GroupOrders & such

seed_group_orders

## Finances

FinancialTransactionType.create!(id: 1, name: 'Foodcoop', financial_transaction_class_id: 1)

FinancialTransaction.create!(id: 1, ordergroup_id: 5, amount: -0.35E2,
                             note: 'Membership fee for ordergroup', user_id: 1, created_on: 'Sat, 18 Jan 2014 00:38:48 UTC +00:00', financial_transaction_type_id: 1)
FinancialTransaction.create!(id: 3, ordergroup_id: 6, amount: -0.35E2,
                             note: 'Membership fee for ordergroup', user_id: 1, created_on: 'Sat, 25 Jan 2014 20:20:37 UTC +00:00', financial_transaction_type_id: 1)
FinancialTransaction.create!(id: 4, ordergroup_id: 7, amount: -0.35E2,
                             note: 'Membership fee for ordergroup', user_id: 1, created_on: 'Mon, 27 Jan 2014 16:22:14 UTC +00:00', financial_transaction_type_id: 1)
FinancialTransaction.create!(id: 5, ordergroup_id: 5, amount: 0.35E2, note: 'payment', user_id: 2,
                             created_on: 'Wed, 05 Feb 2014 16:49:24 UTC +00:00', financial_transaction_type_id: 1)
FinancialTransaction.create!(id: 6, ordergroup_id: 8, amount: 0.90E2, note: 'Bank transfer', user_id: 2,
                             created_on: 'Mon, 17 Feb 2014 16:19:34 UTC +00:00', financial_transaction_type_id: 1)
FinancialTransaction.create!(id: 7, ordergroup_id: 5, amount: 5000, note: 'Bank transfer', user_id: 1,
                             created_on: 'Mon, 18 Feb 2014 16:19:34 UTC +00:00', financial_transaction_type_id: 1)
