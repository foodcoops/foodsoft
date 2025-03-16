require 'faker'

suppliers = Supplier.create!([
  { name: 'Performance test', supplier_category_id: 1,
    address: 'Smallstreet 1, Cookilage', phone: '0123456789', email: 'info@bbakery.test', min_order_quantity: '100' },
])

10000.times do
  Article.create!({ supplier_id: suppliers[0].id,
    quantity: 0 })
  .article_versions.create({ name: Faker::Name.name,
                    note: Faker::Name.name,
                    availability: true,
                    manufacturer:  Faker::Name.name,
                    article_category_id: 1,
                    unit: nil,
                    price: Faker::Number.decimal(l_digits: 2),
                    tax: Faker::Number.decimal(l_digits: 2),
                    deposit: '0.0',
                    supplier_order_unit: 'XPP',
                    price_unit: 'XPP',
                    billing_unit: 'XPP',
                    group_order_unit: 'XPP' })
  end
