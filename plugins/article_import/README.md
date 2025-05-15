# FoodsoftArticleImport
This gem provides FoodsoftArticleImport integration for Ruby on Rails and allows to parse a variety of files containing article information. These article information are standardized or customly declared. Possible File Ending are: .bnn, .BNN, .csv, .CSV . It relies on [roo](https://github.com/roo-rb/roo) to read and parse the data


## Getting started
This is a very simple gem that can be used to extract data from files in the formats .bnn, .xml and .csv.
Given one of the aforementioned files, the gem returns information.

example for foodsoft file:

|Status|Order number|Name|Note|Manufacturer|Origin|Unit|Price (net)|VAT|Deposit|Unit quantity|(Reserved)|(Reserved)|Category|
|--- | --- | --- | --- |--- |--- |--- |--- |--- |--- |--- |--- |--- |--- |
||1234A|Walnuts||Nuttyfarm|CA|500 gr|8.90|7.0|0|6|||Nuts|
|x|4321Z|Tomato juice|Organic|Brownfields|IN|1.5 l|4.35|7.0|0|1|||Juices|
||4322Q|Tomato juice|Organic|Greenfields|TR|1.2 l|4.02|7.0|0|2|||Juices|

bnn file reference:
https://n-bnn.de/leistungen-services/markt-und-produktdaten/schnittstelle

Information about Manufacturer, article category, tax and deposit are conveyed through "bnn codes".
A "bnn code" is a mapping of some abbreviation or number to the relevant data.
The data for suppliers lies at DataNatuRe and we just have a list of some mappings.
Much more codes are needed to make this gem more powerfull. Maybe an xml api to DataNatuRe can be implemented in the futurepossibility.
The list used in this gem is not complete, since it needs data from all manufacturers.
If your local foodcoop posesses keys for article mapping, it is possible to use ypour custom code mapping.

You can extend it for your local foodcoop, if you create a custom_codes.yml, and put it in your root folder. 

extracted article attributes will be:

* name: article name from bnn
* order_number: order number from bnn
* note: extra note from bnn
* manufacturer: e.g. ALN -> AL Naturkost Handels GmbH"
* origin: e.g. "GB"
* article_category: e.g. "0202": Sauermilchprodukte
* unit: 
* price:
* tax: e.g. "1" -> "7.0"
* unit_quantity:
* deposit: e.g. "930190" -> 0.08

## Ruby Version
This gem requires Ruby 2.7