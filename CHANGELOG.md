# [Foodsoft 5.0.0](https://github.com/foodcoops/foodsoft/compare/master...v4.x)
(2026-01-07)

### Bug Fixes

* List attributes to allow to search for SharedArticles ([69de2a8](https://github.com/foodcoops/foodsoft/commit/69de2a885eb7fc1cc8b27ecf75fb6b7c8bf0321b))
* set correct scope for all jobs in a generic way also for retries ([e91fc18](https://github.com/foodcoops/foodsoft/commit/e91fc18ef040f2bc8d6d0e27636108d5c03cf9f7))
* remove max_quantity from schema.rb ([cd3141c](https://github.com/foodcoops/foodsoft/commit/cd3141ce5a3bf3fbb2a031b8f779241b2d972e46))

### Features

* group_order form show a button to my_order_group when insufficient funds ([b2deb0e](https://github.com/foodcoops/foodsoft/commit/b2deb0ed1f93b970a53685580802fed9e6c0e5c1))


# [Foodsoft 4.9](https://github.com/foodcoops/foodsoft/compare/v4.8.1-rc2...v4.9) 
(2024-07-10)


### Bug Fixes

* allow longer bank account descriptions ([#1062](https://github.com/foodcoops/foodsoft/issues/1062)) ([48567cf](https://github.com/foodcoops/foodsoft/commit/48567cff3d410fd5610b719649f889b9048563d7))

### Features

* adapt financial transaction type for online payment provider ([#1008](https://github.com/foodcoops/foodsoft/issues/1008) , PR [#1031](https://github.com/foodcoops/foodsoft/issues/1031)) ([113a14d](https://github.com/foodcoops/foodsoft/commit/113a14d2018476cee1c936155d7a2d9aaf654d64))
* add accounting buttons in order management views (usability enhancement) ([#1061](https://github.com/foodcoops/foodsoft/issues/1061)) ([d6a92bf](https://github.com/foodcoops/foodsoft/commit/d6a92bf62c5875922ff5f7de32d0283ec6c8e08f))
* add online payment provider mollie plugin ([#1008](https://github.com/foodcoops/foodsoft/issues/1008) , PR [#1031](https://github.com/foodcoops/foodsoft/issues/1031)) ([0b7898d](https://github.com/foodcoops/foodsoft/commit/0b7898dfe18ba03c722ff5122237c28220fb10ce))
* move document data from document plugin to active storage ([#1050](https://github.com/foodcoops/foodsoft/issues/1050)) ([f8b92eb](https://github.com/foodcoops/foodsoft/commit/f8b92eb7836ee7a3e0de9a1ffc786a23c922079e))



# Foodsoft 4.8.1
(15 February 2024)


### Bug Fixes

* article convert_unit will fail when unit contains a comma character ([b1fa97d](https://github.com/foodcoops/foodsoft/commit/b1fa97d34d66d140e197107867251db93360f8a5))
* documents sort sql needs Arel.sql ([4df78de](https://github.com/foodcoops/foodsoft/commit/4df78def01fc395f7902deb6f0d11d1d8b8efda7))
* incompatible uri gem ([bae984b](https://github.com/foodcoops/foodsoft/commit/bae984bb3e760bb863410374216c7f6ef50fe93a))
* update ruby image, fix bundler version ([c450368](https://github.com/foodcoops/foodsoft/commit/c45036810eeced044a58dac615a629a7b1fb78d0))
* bug on saving config, fixes [#801](https://github.com/foodcoops/foodsoft/issues/801) ([8b152bf](https://github.com/foodcoops/foodsoft/commit/8b152bfbc0ef375f1f180c92006b62d241c83a2d))
* active storage links for attachments ([#1045](https://github.com/foodcoops/foodsoft/issues/1045)) ([4b7356e](https://github.com/foodcoops/foodsoft/commit/4b7356e7e4993f44590cd62dc9f24642cb94c89a))
* allow_other_host for discourse plugin redirects ([#1043](https://github.com/foodcoops/foodsoft/issues/1043)) ([8836697](https://github.com/foodcoops/foodsoft/commit/8836697ed7d9d3137d7797067a2db9e9208a6440))
* **finance:** ordergroup overview total balances ([#1051](https://github.com/foodcoops/foodsoft/issues/1051)) ([a5861f5](https://github.com/foodcoops/foodsoft/commit/a5861f55855dfbe5ce343d4d1896121ccf14471d))

### Features

* **messages:** show recipients in thread view ([9ee8a8f](https://github.com/foodcoops/foodsoft/commit/9ee8a8f85bf4d912276dbfac58bbbaa1e14cde1d))
* use active storage for invoice attachments ([0ff74e8](https://github.com/foodcoops/foodsoft/commit/0ff74e8a46c1c46be1574f74f4365f2e6870a386)), closes [#1037](https://github.com/foodcoops/foodsoft/issues/1037)
* remove the feedback form ([9c81aa3](https://github.com/foodcoops/foodsoft/commit/9c81aa3b7e3b4b045ab32ba58a9b653458382169))


# Foodsoft 4.8.0

* feat: Show total sums for ordergroup finances [#1017](https://github.com/foodcoops/foodsoft/pull/1017)
* feat: Richtext Messages and Attachments with Actiontext [#918](https://github.com/foodcoops/foodsoft/issues/918)
* feat: Make date configurable via locales [#997](https://github.com/foodcoops/foodsoft/pull/997)
* feat: Turkish language support added [#995](https://github.com/foodcoops/foodsoft/pull/995)
* feat: Disable member list via configuration [#990](https://github.com/foodcoops/foodsoft/pull/990)
* feat: Specify an URL to redirect after logout via settings #989
* feat: introduce importmaps [#983](https://github.com/foodcoops/foodsoft/pull/983)
* feat: ruby 2.7.2 and rails 7 upgrade [#979](https://github.com/foodcoops/foodsoft/pull/979)
* feat: Add home controller test [#972](https://github.com/foodcoops/foodsoft/pull/972)
* feat: Replace apivore with rswag for api tests [#969](https://github.com/foodcoops/foodsoft/pull/969)
* feat: increase test coverage [#966](https://github.com/foodcoops/foodsoft/pull/966)
* feat: Show order note as tooltip [#965](https://github.com/foodcoops/foodsoft/pull/965)
* feat: Add sd_notify [#961](https://github.com/foodcoops/foodsoft/pull/961)
* feat: Show instance name at login screen [#957](https://github.com/foodcoops/foodsoft/pull/957)
* feat: Enabled systemd socket activation [#942](https://github.com/foodcoops/foodsoft/pull/942)
* feat: Add table_print gem for debugging ActiveRecord queries in the console [#935](https://github.com/foodcoops/foodsoft/pull/935)
* feat: Add admin UI for SupplierCategories (supplier_categories) [#930](https://github.com/foodcoops/foodsoft/pull/930)

* fix: add null checks for articles convert_units [33034e6](https://github.com/foodcoops/foodsoft/commit/33034e66b88968dedc5289425e1eff847ee67e12)
* fix: downgrade haml to make deface work [#1003](https://github.com/foodcoops/foodsoft/pull/1003)
* fix: dutch translation errors [#954](https://github.com/foodcoops/foodsoft/pull/954)
* fix: Fixe filtering of active ordergroups [#934](https://github.com/foodcoops/foodsoft/pull/934)
* fix: Change password validation to allow longer passwords [#923](https://github.com/foodcoops/foodsoft/pull/923)
* fix: Invoice: change label "delivery" to "stock delivery" [#922](https://github.com/foodcoops/foodsoft/pull/922)
* fix: Allow decimal numbers in transaction collections [#921](https://github.com/foodcoops/foodsoft/pull/921)
* fix: Add validation of more article fields [#917](https://github.com/foodcoops/foodsoft/pull/917/files)
* fix: Add default time_zone [#912](https://github.com/foodcoops/foodsoft/pull/912)
* fix: Rename Piwik to Matomo [#911](https://github.com/foodcoops/foodsoft/pull/911/files)
* fix: Change instructions to rbenv [#910](https://github.com/foodcoops/foodsoft/pull/910/files)


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