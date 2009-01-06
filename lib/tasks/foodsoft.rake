# put in here all foodsoft tasks
# => :environment loads the environment an gives easy access to the application

namespace :foodsoft do

	# "rake foodsoft:create_admin"
	desc "creates Administrators-group and admin-user"
	task :create_admin => :environment do
		puts "Create Group 'Administators'"
	  administrators = Group.create(:name => "Administrators", 
	  															:description => "System administrators.", 
	  															:role_admin => true,
	  															:role_finance => true,
	  															:role_article_meta => true,
	  															:role_suppliers => true,
                                  :role_orders => true)
	  
	  puts "Create User 'admin' with password 'secret'"
	  admin = User.new(:nick => "admin", :first_name => "Anton", :last_name => "Administrator", :email => "admin@foo.test")
	  admin.password = "secret"
	  admin.save
	  
	  puts "Joining 'admin' user to 'Administrators' group"
	  Membership.create(:group => administrators, :user => admin)
	end
end