---
title: First Steps
description: Foodsoft installation and development
published: true
date: 2025-09-10T08:25:59.631Z
tags: 
editor: markdown
dateCreated: 2021-10-01T12:20:11.258Z
---

Foodsoft is freely accessible software, written in the Ruby language based on Rails. The source code is publicly accessible on the GitHub web platform.

# GitHub Repositories

Through this platform you can
- download Foodsoft to
  - install it locally on your computer to try it out or make changes to the source code and test them
  - install it on a web server to make it accessible to members of your food cooperative
- submit issues when you discover bugs or want new features, and also view and comment on issues from others (e.g., like: yes this is also relevant for me)
- upload modified or newly written source code for change and extension suggestions (Pull Requests), which will hopefully be approved by others so they are "committed" and thus officially become part of Foodsoft

The following links lead to the GitHub repositories:
- https://github.com/foodcoops/foodsoft – the main branch of Foodsoft. Once you register and make changes yourself, you should create a fork for your changes, which will then be accessible at https://github.com/YOUR_GITHUB_USERNAME/foodsoft.
   - Documentation for Foodsoft development: https://github.com/foodcoops/foodsoft/tree/master/doc
- https://github.com/foodcoopsat/foodsoft – a fork of the main branch that should reflect the state of Foodsoft on the IG Foodcoops server (https://app.foodcoops.at/...). Some extensions are integrated here for Austrian food cooperatives that are not "relevant" for food cooperatives in other countries.
- https://github.com/bankproxy - Extension for bank connection Austrian banks

# Foodsoft Installation

## Instructions on GitHub

> Installation via [Docker](https://en.wikipedia.org/wiki/Docker_(software)) requires fewer steps and prior knowledge, and is therefore easier to perform than manual setup.
{.is-info}

- [Foodsoft setup manual](https://github.com/foodcoops/foodsoft/blob/master/doc/SETUP_DEVELOPMENT.md)
- [Foodsoft setup Docker](https://github.com/foodcoops/foodsoft/blob/master/doc/SETUP_DEVELOPMENT_DOCKER.md)
{.links-list}

## Additional Installation Notes

- If a step doesn't work, try restarting the computer, e.g., after installing Docker software.
- Before downloading your Foodsoft branch, execute *Fetch Upstream > Fetch and Merge* to bring all files of your branch to the latest state. Outdated files can cause installation errors.
- Download your Foodsoft branch with `git clone https://github.com/YOUR_USERNAME/foodsoft.git`; this creates a `foodsoft` directory in the current directory containing all necessary files.
- If it doesn't work with your branch, you can also download the Foodsoft master as a ZIP file and extract it. However, locally made changes to the code can then no longer be easily uploaded to GitHub.
- Before installing Foodsoft (whether manual or via Docker) after download, change to the directory: `cd foodsoft` or `cd foodsoft-master`
- Start Foodsoft:
  - manual installation: `bundle exec rails s`
  - Docker: `docker-compose -f docker-compose-dev.yml up`
  - Web browser: in both cases open URL `http://localhost:3000/`, User: admin, Password: secret

## Import Database

If you have an image of your Foodsoft database as a `database.sql` file, you can import it into your local installation:

### Manual Foodsoft Installation
After manual installation of Foodsoft and when using a mysql database:
`mysql –u root –p foodsoft_development < database.sql`

### Docker Foodsoft Installation
Both PhpMyAdmin and direct mysql calls have problems with direct import of the Foodsoft database when it is somewhat larger (which happens quickly, example where it didn't work: total export results in 510 MB large SQL file).

> One possibility would be to increase the limits in the Docker environment accordingly, but this requires quite deep knowledge. Adding corresponding lines in `docker-compose-dev.yml` (lines 7,8 in the example below) leads to an error when restarting the Docker environment and can subsequently cause the entire Docker environment to no longer run!
{.is-warning}

```
  phpmyadmin:
  image: phpmyadmin/phpmyadmin
  environment:
    - PMA_HOST=mariadb
    - PMA_USER=root
    - PMA_PASSWORD=secret
    - UPLOAD_LIMIT=900M
    - MEMORY_LIMIT=1G
```

Therefore, it is recommended to export only the really needed tables as described below and especially leave out large tables, thereby reducing the SQL file size from 510 to about 50 MB in the example.

- Export the MySQL database of Foodsoft: via PhpMyAdmin go to the [food cooperative database](/en/documentation/admin/database) *foodcoop_...* Export with the options:
  - Export method: Custom
  - Export in a single transaction
  - Disable foreign key checks (?)
  - Tables: for large tables uncheck *Data*, here with % of data usage of an exemplary food cooperative instance (italicized ones are essential for ordering processes, so rather not leave out). When exporting, the storage space requirement can still change as binary data is encoded as ASCII characters:
    - documents : 50 %
    - messages : 9 %
    - message_recipients : 6 %
    - *order_articles* : 6 %
    - *group_order_articles* : 6 %
    - action_text_rich_texts : 4 %
    - page_versions : 3 %
    - *financial_transactions* : 3 %
    - *group_order_article_quantities* : 3 %
    - *group_orders* : 2 %
    - *stock_changes* : 1 %
    - mail_delivery_status : 1 %
    - *articles* : 1 %
    - oauth_access_grants : 1 %
    - *article_prices* : 1 %
    - *orders* : 1 %
    - pages : 1 %
  - Unneeded tables can also be unchecked if they cause problems during import. Individual tables can also be loaded later. In the example, it worked by leaving out the data from tables *documents, messages and messages_recipients*: documents due to high data volume, messages because there were problems with the imported data.
  
  - Filename e.g.: `foodsoft_fcname.sql`
- Start the local Foodsoft instance and from the line
  `Starting 018f6f520723_foodsoft_mariadb_1         ... done`
  copy the designation of the mariadb Docker instance, here: `018f6f520723_foodsoft_mariadb_1`
- Start PhpMyAdmin in the local instance in the web browser via the URL [localhost:2080](http://localhost:2080)
  - Rename the database *development* to *development_original*
  - Create a new empty database with the name *development*
- In a second terminal enter (don't stop the running Docker instance in the first terminal) and after `-i` copy in the Docker instance from before:
  `docker exec -i 018f6f520723_foodsoft_mariadb_1 mysql -uroot -psecret development < foodsoft_fcname.sql`

### Adjust Settings
The Foodsoft settings in the *settings* table are not adopted during import because the food cooperative name appears in the setting names (settings > var), but in the local installation "f" is used as the food cooperative designation. In the local database, this can be adjusted in phpMyAdmin with the following SQL command, here in the example for the food cooperative *franckkistl*:

```
UPDATE settings
SET var = REPLACE(var, 'foodcoop.franckkistl.', 'foodcoop.f.')
WHERE var LIKE 'foodcoop.franckkistl.%';
```
> The food cooperative name appears twice (lines 2 and 3) and must be replaced with the appropriate one in both places!
{.is-warning}

# Ruby on Rails
General introductions to the Ruby framework for web applications:
- https://www.tutorialspoint.com/ruby-on-rails/rails-introduction.htm
- Ruby in 20 Minutes: https://www.ruby-lang.org/en/documentation/quickstart/

# Used Tools

- **Ransack** enables the creation of both simple and advanced search forms for your Ruby on Rails application: https://github.com/activerecord-hackery/ransack/blob/master/README.md
- **Simple Form** aims to be as flexible as possible while helping you with powerful components to create your forms: https://github.com/heartcombo/simple_form

# Foodsoft Data Structure

https://github.com/foodcoop-adam/foodcoop-adam.github.io/blob/developer-docs/design_diagrams/201404-generated_erd_v3.pdf

> Foodsoft is built on a database with > 50 tables. The structure of this database is largely not defined in the program code, so you always have to read the code and the database together to know all available data and their designations.
{.is-info}

# Foodsoft File Structure

https://github.com/foodcoops/foodsoft/

Where to find what in the code?

## app/models/
Database specifications: app/models/...
- Character count limitations for input fields
- Input validations: e.g., unique (name may only be assigned once, e.g., for article names)

## app/views/
Here the individual websites of Foodsoft are defined via .haml files. The Foodsoft page https://app.foodcoops.at/fc-name/finance/balancing can be found e.g., in apps/views/finance/balancing. To build the page content, these files access database entries and Foodsoft methods (functions). This is often a good starting point to find code.

## app/controllers/
Here data processing takes place. /app/controllers/orders_controller.rb contains e.g., methods to finish orders (finish) and send them to the supplier (send_result_to_supplier).

## config/
Translation texts for German Foodsoft version editable via
  - https://crowdin.com/translate/foodsoft/ - is only adopted 1-2 times a year when a "real release" comes out
  - `config/locales/de.yml`

> This is just an excerpt, please feel free to expand!
{.is-danger}

# API

External applications can connect to Foodsoft via the API and exchange data or perform actions in Foodsoft.

## API V1
- https://raw.githubusercontent.com/foodcoops/foodsoft/master/doc/swagger.v1.yml

Query strings description:
https://github.com/activerecord-hackery/ransack

Set up Oauth2 access to Foodsoft:
- https://app.foodcoops.at/...foodcoop.../oauth/applications
- https://app.foodcoops.at/demo/oauth/applications
- http://localhost:3000/f/oauth/applications

## Example Codes

> Coming as soon as available...
{.is-danger}