# Create nessecary data to start with a fresh installation

# Create working group with full rights
administrators = Workgroup.create(
    :name => "Administrators",
    :description => "System administrators.",
    :role_admin => true,
    :role_finance => true,
    :role_article_meta => true,
    :role_suppliers => true,
    :role_orders => true
)

# Create admin user
User.create(
    :nick => "admin",
    :first_name => "Anton",
    :last_name => "Administrator",
    :email => "admin@foo.test",
    :password => "secret",
    :groups => [administrators]
)

# First entry for article categories
ArticleCategory.create(:name => "Other", :description => "other, misc, unknown")
