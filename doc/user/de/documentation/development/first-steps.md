---
title: Erste Schritte
description: Foodsoft Installation und Entwicklung
published: true
date: 2025-09-10T08:25:59.631Z
tags: 
editor: markdown
dateCreated: 2021-10-01T12:20:11.258Z
---

Die Foodsoft ist eine frei zugängliche Software, geschrieben in der Sprache Ruby basierend auf Rails. Die Quelltexte dafür sind auf der Web-Plattform Github öffentlich zugänglich. 

# Github Repositories

Über diese Plattform kannst du 
- die Foodsoft herunterladen, um sie 
  - auf deinem Rechner lokal zu installieren, um sie dort auszuprobieren oder auch Änderungen im Quelltext durchzuführen und sie zu testen
  - auf einem Webserver zu installieren, um sie den Mitgliedern deiner Foodcoop zugänglich zu machen
- Issues einbringen, wenn du auf Fehler (Bugs) draufgekommen bist, oder dir neue Funktionen wünscht, und auch  Issues von anderen einsehen und kommentieren (z.B. in der Art wie: ja das ist für mich auch relevant)
-  Von dir modifizierte oder neu geschriebene Quellcodes für Änderungs- und Erweiterungsvorschläge hochladen (Pull Requests), die dann hoffentlich von den anderen für gut geheißen werden, sodass sie „commited“ werden und damit offiziell Teil der Foodsoft werden

Folgende Links führen zu den Github Repositories:
- https://github.com/foodcoops/foodsoft – der Hauptzweig der Foodsoft. Sobald du dich registrierst und selbst Änderungen durchführst, solltest du einen Fork für deine Änderungen anlegen, der dann unter https://github.com/DEIN_GITHUB_BENUTZERNAME/foodsoft erreichbar ist.
   - Dokumentation zur Foodsoft Entwicklung: https://github.com/foodcoops/foodsoft/tree/master/doc
- https://github.com/foodcoopsat/foodsoft – eine Abspaltung („Fork“) des Hauptzweigs, der den Stand der Foodsoft am IG Foodcoops Server (https://app.foodcoops.at/...) wiederspiegeln sollte. Manche Erweiterungen sind hier für die österreichischen Foodcoops integriert, die für Foodcoops in anderen Ländern nicht „relevant“ sind.
- https://github.com/bankproxy - Erweiterung für Bankanbindung österreichische Banken
# Installation der Foodsoft

## Anleitungen auf Github

> Die Installation über [Docker](https://de.wikipedia.org/wiki/Docker_(Software)) erfordert weniger Schritte und Vorkenntnisse, und ist daher einfacher durchzuführen als das manuelle Setup. 
{.is-info}

- [Foodsoft setup manuell](https://github.com/foodcoops/foodsoft/blob/master/doc/SETUP_DEVELOPMENT.md)
- [Foodsoft setup Docker](https://github.com/foodcoops/foodsoft/blob/master/doc/SETUP_DEVELOPMENT_DOCKER.md)
{.links-list}


## Ergänzende Hinweise zur Installation

- Wenn ein Schritt nicht klappt, einen Neustart des Computers versuchen, z.B. nach  Installation der Docker Software.
- Vor dem Download deines Foodsoft Branches *Fetch Upstream > Fetch and Merge* ausführen, um alle Dateien deines Branches auf den aktuellsten Stand zu bringen. Mit veralteten Dateien kann es zu Fehlern bei der Installation kommen.
- Deinen Branch der Foodsoft herunterladen mit `git clone https://github.com/YOUR_USERNAME/foodsoft.git`; es entsteht im aktuellen Verzeichnis ein Verzeichnis `foodsoft`, das alle benötigten Dateien enthält.
- Wenn es mit deinem Branch nicht klappt, kannst du auch den Foodsoft-Master als ZIP Datei herunterladen und entpacken. Lokal durchgeführte Änderungen im Code können dann allerdings nicht mehr so einfach auf Github hochgeladen werden.
- Vor der Installation der Foodsoft (egal ob manuell oder über Docker) nach dem Download in das Verzeichnis wechseln: `cd foodsoft` bzw. `cd foodsoft-master`
- Foodsoft starten: 
  - manuelle Installation:  `bundle exec rails s`
  - Docker: `docker-compose -f docker-compose-dev.yml up`
  - Webbrowser: in beiden Fällen URL `http://localhost:3000/` öffnen, User: admin, Password: secret

## Datenbank importieren

Wenn du ein Abbild deiner Foodsoft-Datenbank als `datenbank.sql` Datei hast, kannst du es in deine lokale Installation einspielen:

### Manuelle Foodsoft Installation
Nach manueller Installation der Foodsoft und bei Verwendung einer mysql Datenbank: 
`mysql –u root –p foodsoft_development < datenbank.sql`

### Docker Foodsoft Installation
Sowohl PhpMyAdmin als auch der direkte Aufruf von mysql haben Probleme beim direkten Import der Foodsoft Datenbank, wenn diese etwas größer ist (was schnell mal der Fall ist, Beispiel wo es nicht funktioniert hat: Gesamexport ergibt 510 MB großes SQL-File). 

> Eine Möglichkeit wäre, die Limits in der Docker-Umgebung entsprechend zu erhöhen, aber das erfordert recht tiefgehende Kenntnisse. Im `docker-compose-dev.yml` entsprechende Zeilen einzufügen (Zeile 7,8 im Beispiel unten), führt beim Neustart der Docker-Umgebung zu einem Fehler und kann in weiterer Folge dazu führen, dass die ganze Docker-Umgebung nicht mehr läuft!
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
Daher empfihelt sich, wie folgt beschrieben nur die wirklich benötigten Tabellen zu exportieren und vor allem große Tabellen weg zu lassen, dadurch ist im Beispiel die SQL-File Gröe von 510 auf etwa 50 MB gesunken.

- Die mySql Datenbank der Foodosft exportieren: über PhpMyAdmin auf die [Datenbank der Foodcoop](/de/documentation/admin/datenbank) gehen *foodcoop_...* Exportieren mit den Optionen:
  - Exportmethode: Angepasst
  - Export in einer Transaktion zusammenfassen
  - Fremdschlüsselüberprüfung deaktivieren (?)
  - Tabellen: bei großen Tabellen *Daten* weggklicken, hier mit % der Datenbelegung einer exemplarischen Foodcoop Instanz (kursiv dargestellte sind für die Bestellabläufe essenziell, daher eher nicht weglassen). Beim Exportieren kann sich der Speicherplatzbedarf noch verändern, da binäre Daten als ASCII Zeichen kodiert werden:
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
  - nicht benötigte Tabellen können auch weg gecklickt werden, wenn z.B. sie beim Importieren Probleme machen. Einzelne Tabellen können auch später nachgeladen werden. Im Beispiel hat es funktioniert, indem die Daten der Tabellen *documents, messages und messages_recepients* weg gelassen wurden: documents aufgrund der hohen Datenmenge, messages weil es Probleme mit den importierten Daten gab. 
  
  - Dateiname z.B: `foodsoft_fcname.sql`
- Die lokale Foodsoft Instanz starten und aus der Zeile
  `Starting 018f6f520723_foodsoft_mariadb_1         ... done`
  die Bezeichnung der mariadb Dockerinstanz kopieren, hier: `018f6f520723_foodsoft_mariadb_1`
- PhpMyAdmin in der lokalen Instanz starten im Webbrowser über die Url [localhost:2080](http://localhost:2080)
  - Die Datenbank *development* umbenennen in *development_original* 
  - eine neue leere Datenbank mit dem Namen *development* erstellen 
- In einem zweiten Terminal eingeben (die laufende Docker-Instanz im ersten Terminal nicht beenden) und nach `-i` die Dockerinstanz von vorhin hineinkopieren: 
  `docker exec -i 018f6f520723_foodsoft_mariadb_1 mysql -uroot -psecret development < foodsoft_fcname.sql`


### Settings anpassen
Die Einstellungen der Foodsoft in der *settings* Tabelle werden beim Import nicht übernommen, weil in den Namen der Einstellungen (settings > var) der FoodCoop-Name vorkommt, aber in der lokalen Installation wird "f" als FoodCoop Bezeichnung verwendet. In der lokalen Datenbank kann das in phpMyAdmin mit dem folgenden SQL-Befehl angepasst werden, hier im Beispiel für die FoodCoop *franckkistl*:

```
UPDATE settings
SET var = REPLACE(var, 'foodcoop.franckkistl.', 'foodcoop.f.')
WHERE var LIKE 'foodcoop.franckkistl.%';
```
> Der Name der FoodCoop kommt 2 Mal vor (Zeile 2 und 3) und muss an beiden Stellen durch den zutreffenden ersetzt werden!
{.is-warning}








# Ruby on Rails 
Allgemeine Einführungen zum Ruby Framework für Web-Applikationen:
- https://www.tutorialspoint.com/ruby-on-rails/rails-introduction.htm 
- Ruby in 20 Minutes: https://www.ruby-lang.org/en/documentation/quickstart/  
# Verwendete Tools

- **Ransack** enables the creation of both simple and advanced search forms for your Ruby on Rails application: https://github.com/activerecord-hackery/ransack/blob/master/README.md
- **Simple Form** aims to be as flexible as possible while helping you with powerful components to create your forms: https://github.com/heartcombo/simple_form


# Foodsoft Daten Struktur

https://github.com/foodcoop-adam/foodcoop-adam.github.io/blob/developer-docs/design_diagrams/201404-generated_erd_v3.pdf

> Die Foodsoft baut auf eine Datenbank mit > 50 Tabellen auf. Die Struktur dieser Datenbank ist im Programmcode großteils nicht definiert, man muss also immer den Code und die Datenbank gemeinsam lesen, um alle verfügbaren Daten und ihre Bezeichnungen zu wissen. 
{.is-info}


# Foodsoft Dateistruktur

https://github.com/foodcoops/foodsoft/ 

Wo ist im Code was zu finden? 

## app/models/
Datenbank Spezifikationen: app/models/...
- Zeichenanzahl  Begrenzungen für Eingabefelder
- Überprüfungen von Eingaben: z.B. unique (Name darf nur einmal vergeben werden, z.B. bei Artikelnamen)

## app/views/
Hier werden die einzelnen Websites der Foodsoft über .haml Dateien definiert. Die Foodosoft Seite https://app.foodcoops.at/fc-name/finance/balancing findet sich z.B. in apps/views/finance/balancing. Zum Aufbau der Seiteninhalte greifen diese Files auf Datenbank Einträge und Foodsoft Methoden (Funktionen) zu. Das ist oft ein guter Einstieg, um Code aufzufinden. 

## app/controllers/
Hier finden Datenverarbeitungen statt. /app/controllers/orders_controller.rb enthält z.B. Methoden, um Bestellungen zu beenden (finish), und sie an die Lieferantin zu senden (send_result_to_supplier).  

## config/
Übersetzungstexte für deutsche Foodsoft Version bearbeitbar über
  - https://crowdin.com/translate/foodsoft/ - wird nur 1-2 mal im Jahr übernommen, wenn ein „echtes Release“ herauskommt
  - `config/locales/de.yml` 

> Hier nur ein Auszug, bitte gerne erweitern!
{.is-danger}

# API 

Über das API können sich externe Anwendungen mit der Foodsoft verbinden und Daten austauschen bzw. Aktionen in der Foodsoft durchführen. 

## API V1
- https://raw.githubusercontent.com/foodcoops/foodsoft/master/doc/swagger.v1.yml

Query-Strings Beschreibung:
https://github.com/activerecord-hackery/ransack

Oauth2 Zugang zur Foodsoft einrichten:
- https://app.foodcoops.at/...foodcoop.../oauth/applications
- https://app.foodcoops.at/demo/oauth/applications
- http://localhost:3000/f/oauth/applications

## Beispiel-Codes

> Kommt sobald verfügbar...
{.is-danger}
