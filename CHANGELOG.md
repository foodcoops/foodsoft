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
