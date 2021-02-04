# Foodsoft 4.7.1
(31 December 2020)

* Fix minor navigation glitch ([78c4ebc](https://github.com/foodcoops/foodsoft/commit/78c4ebcb4b61891e13d3dbb9f07c34ad88c41f4a))
* Fix legacy tasks without user ([beaca7d](https://github.com/foodcoops/foodsoft/commit/beaca7d384bf9c9a9c5275ac7d81bb012374372e))
* Fix GroupOrder update timestamp ([3d5043f](https://github.com/foodcoops/foodsoft/commit/3d5043fd052f79b33f8cae2ea3a5cc81ee972ba5))
* Fix searching in external database ([4043433](https://github.com/foodcoops/foodsoft/commit/4043433539f34b880bec8826d2f29f9137412ef4))

# Foodsoft 4.7.0
(11 September 2020)

* Add download for articles
* Add search to balancing page (#651)
* Fix to not allow changes to settled orders (#614)
* Fix to improve ordering on smaller screens (#668)
* Fix to not show deleted shared suppliers
* Fix for anchor links in wiki
* Fix to show private messages in index pages (#106)
* Fix to only show started orders in member ordering
* Allow to copy articles (#541)
* Allow making public messages private (#625)
* Allow reverting financial transactions (ff76fa)
* Send mails to suppliers in the default language
* Do not show deleted users as group members (#587)
* Show associated group when sending messages (#559)
* CSV download for ordergroups (71fd6f)
* Speedup sync (#610)
* Improve usability when ordering (#552)
* Show the sitemap on the Wiki index
* Better support for a pickup day, including PDFs with all orders and a pickups role
* Add transport costs per order, which can be distributed over members
* Add financial types and classes
* Add bank accounts, including importing transactions
* Add financial links to link financial transactions with invoices, orders and bank transactions
* Allow creating transactions for ordergroups with a custom field (a3defc)
* Allow more than 20 page versions in the wiki
* Add polls plugin
* Folders for the documents plugin (dc94e9)
* Allow moving of documents
* New printer job queue plugin, to easily print documents from within Foodsoft
* Initial work an API, so that external applications can work with Foodsoft

Note that this releases uses Rails 5.2 under hood.

# Foodsoft 4.6.0
(10 November 2017)

* Foodsoft can now be used in the Spanish language (3b18dc, #525)
* A Docker image for production use (#482, #497)
* Allow to send order PDF automatically on specified closing time (#488, #495, #515)
* The documents plugin is now included by default (#514)
* A new plugin to integrate login with Discourse forum software (#478, #502)
* Improved user-interface for selecting who to send a message to (#506)
* You can now create a wiki page called Dashboard to show on top of the dashboard (#519)
* A new view for showing unpaid invoices (#520)
* User, supplier, ordergroups and invoices can now receive custom fields in the app configuration (#516)
* Cleaner message replies when received by email (#504)
* Better support for running Foodsoft in a sub-path (#500)
* Sort workgroup tasks by name (#487)
* Allow plugins to create links to financial transactions (#517)
* The license has been changed to AGPL (#513)
* Fix foodcoop price calculation when changed in database (#506)
* Fix to notify users of tasks (#494)
* Fix to not show deleted users in forms (#486)
* Fix to include stock articles in groups document (#478)
* Please note that support for deployment with Capistrano has been removed (#491)

Please note that support for deployment with Capistrano has been removed (#491). The license has been changed to
AGPL: if you are running a modified version of Foodsoft, from this version on, you need to share your changes.

# Foodsoft 4.5.2
(17 April 2017)

* The messages plugin can now receive replies by email when setup (#459)
* Add Copy button for settled orders (#383)
* Fix to not send messages to deleted users (462)
* Fix to allow adding an invoice to finished orders (925727)
* Fix to make sure new periodic tasks aren't done (#454)
* Fixes for several security vulnerabilities

# Foodsoft 4.5.1
(12 August 2016)

* Fix adding articles in the delivery and receive screens
* Fix overview of all wiki pages

# Foodsoft 4.5.0
(28 June 2016)

* Improve Docker setup. (#399)
* Speedup generation of most PDFs (#433)
* New plugin for working with current orders (closed but not finished) (#373)
* New plugin for sharing documents (#353)
* Allow attaching an image or PDF to an invoice (#345)
* Add an expected delivery / pickup date to orders (#355)
* Add an optional box-fill phase to orders (#387)
* Add color marking to items in group orders that have missing items (#365)
* Allow ordering articles for stock as part of a regular order (alternative for deliveries)
* Allow ordergroups to have a break period (like holiday) (#404)
* Add message groups (#402)
* Add message threads (#394)
* Add invoice role for submitting invoices (1315103)
* Improvements for wiki pages (#419, #420)
* Allow disabling invitation functionality (#416)
* Allow adding all ordergroups when creating multiple financial transactions (#414)
* Allow message replies using emails (4e35e2d)
* User-interface improvements (#417, #411, #392, #391, #388, e.a.)
* Soft-delete users to fix some problems (#386, #406)
* Show error pages in regular layout when possible (#375)
* Fix some problems with stock articles
* Fix order schedule not being able to be cleared
* Fix unicode characters in PDF documents

If you've used the Docker configuration before, please make sure to delete
the old files (`sudo rm -Rf tmp/* log/*`) and rebuild the container with
`docker-compose build`.

# Foodsoft 4.4.1
(5 Jun 2015)

* Fix external dependency causing installation failure (#369)

# Foodsoft 4.4.0
(15 May 2015)

* Let upload provide same functionality as shared database sync (#113, #361)
* Read Excel and Openoffice spreadsheets in upload (#113, #361)
* Allow to add text to login page using wiki (edit `Public_frontpage`)
* Add expansion variables for footer and wiki pages
* Enable editing of recurring tasks (#152)
* Show only suppliers with articles for new orders (#347)
* Show recipients of messages (#354)
* Allow to open an order based on a previous one (#348)
* Allow to send message to people who ordered (#350)
* Remember when user was last active (#357)
* Use icons for permissions
* Improve header and footer in PDFs
* Get rid of last empty page in PDFs
* Add uservoice plugin for gathering user feedback (#333)
* Fix message mails not always being delivered by setting sender (#349)
* Fix sync when unit has no name (#337)
* Fix updating profile when user has no ordergroup
* Fix deleted ordergroups being shown (#362)

# Foodsoft 4.3.0
(31 Dec 2014)

* Allow to edit address from user profile (#332)
* Cleanup groups in user profile screen (bf6a31)
* Allow admins to login as a different user (#323)
* Hide message preferences when messages are disabled (618856)
* Allow to specify an order schedule for new orders (#329)
* Allow to configure how many weeks tasks are scheduled upfront (#324)
* Allow account balance to become really large or small (#332)
* Plugins moved to a new directory (#330)

# Foodsoft 4.2.0
(14 Oct 2014)

* Allow foodcoops to configure their settings (#298)
* Allow foodcoops to add a CSS style (#306)
* Allow foodcoops to enter a tracking code for web statistics (#331)
* Times are now shown in the foodcoop's timezone (#282)
* Synchronisation improvements: category matching + full assortment sync (#287)
* Fix strange characters in text mails (don't escape HTML)
* Allow to set page break options for each document
* Allow to receive >200 articles (#305)
* Show articles ordered by members but not by foodcoop dimmed in receive
* Order articles by number then name in Fax PDF and receive (for easier checking)
* Show message when errors occur in dynamic interaction (ajax) (#300)

# Foodsoft 4.1.0
(23 Jun 2014)

* Add pdf configuration options for fontsize, pagesize and -breaks (#274)
* Performance improvement: zero quantities are not stored anymore, which is especially noticable in large order lists. (#273)
* The potentially dangerous 'settle directly' button was moved to the order's balancing screen. (#276)
* New screen to view all transactions (#285)
* Extract message system to plugin (#271)
* Cleanup email footer (#269)
* Cleanup website footer (#295)
* Use member language when sending mails
* Be more intelligent when parsing units during shared database sync (using ruby-units) (#272)
* Give articles that will be ordered but have a shortage a different colour (#293)
* Add order fax CSV in addition to PDF and text (#270)
* Add configuration for default language (#264)
* Make apple points optional (#266)
* Allow 500 items per page (#265)
* Cleaner and expanded show supplier view (#262)
* External database user-interface tweaks (#261)
* Cleanup form for creating a new order (#263)
* Fix member ordering on Internet Explorer 11+
* Don't wrap around number when displaying currency
* Don't display superfluous zeroes for numbers
* Fix sort order in orders overview

# Foodsoft 4.0.0
(24 Feb 2014)

Note: when you value stability, please wait for foodsoft 4.1.0.

* Upgrade to Rails 4 (#214)

# Foodsoft 3.3.0
(24 Feb 2014)

* New improvements the stock section.
* New receive screen for redistributing articles when the order is closed. Members with orders and finance permission are now able to change the amount received, and redistribute that over the members.
* Amounts received by ordergroups can now be edited directly in the ordergroup and article list.
* Redesigned article edit dialog.
* Do not offer to add deleted articles in the balancing screen.
* Work nicely with browsers remembering passwords.
* Add RSS feed for wiki updates (navigate to Wiki -> All pages).
* Clearer error message when a wiki page contains a syntax error.
* More graceful response on access denied errors.
* Touch devices are now better supported.
* Added some missing translations.
* Other small fixes.

# Foodsoft 3.2.0
(16 December 2013)

It's been a year since the previous release. Much has changed. Big changes have been:

* Translations to English, Dutch and French.
* Improved usability of delivery creation.
* The possibility to extend foodsoft with plugins (the wiki is now optional).
* Article search in the ordering screen.
* Foodcoops can choose to use full names and emails instead of nicknames.
* Foodcoops that don't use prepaid can set their minimum ordergroup balance below zero.
* Group and article PDFs now show articles ordered but not received in grey.
* Upgrade to Rails 3.

When you upgrade, be sure to review `config/app_config.yml.SAMPLE`. When you're running multiple foodcoops from a single installation, check your rake invocations as the syntax is now: `rake multicoops:run TASK=db:migrate`.

# Foodsoft 3.1.1
(20 July 2012)
