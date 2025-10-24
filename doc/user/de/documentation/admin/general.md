---
title: Überblick
description: Funktionsüberblick und Einsatzmöglichkeiten der Foodsoft
published: true
date: 2021-11-26T11:06:26.697Z
tags: 
editor: markdown
dateCreated: 2021-04-20T19:57:55.363Z
---

# Einleitung
In diesem Teil der Dokumentationen sind Funktionen der Foodsoft beschrieben, die zur Einrichtung und Administration erforderlich sind. Diese Funktionen sind nur für Foodsoft Benutzerinnen mit entsprechenden Zugriffsrechten verfügbar (siehe [Benutzerinnenverwaltung](/de/documentation/admin/users)).

Die Funktionen der Foodsoft werden ständig erweitert, machmal kann es sein, dass eine neue Funktion noch nicht hier dokumentiert ist. Bitte trag selbst etwas bei, indem du eine Beschreibung, oder zumindest an der passenden Stelle eine Überschrift hinzufügst.

# Funktionsüberblick - was die Foodsoft alles kann

## Typische Foodcoop-Abläufe und die jeweilige Unterstützung durch die Foodsoft

So könnte ein typischer Wochenablauf in einer Foodcoop mit einem wöchentlichen Bestellrhythmus aussehen:

1.  Samstag:
FC-Mitglied legt in der **Foodsoft Bestellungen** an, offen von Samstag bis Mittwoch, schickt **über die Foodosft eine Nachricht an alle** zur Info aus.
2.  Samstag bis Mittwoch: 
FC-Mitglieder bestellen oder verändern ihre **Bestellungen über die Foodsoft**; dazu müssen sie vorher ihr Guthaben aufgeladen haben, und können nur so lange bestellen, bis das Guthaben erschöpft ist. Das Guthaben bleibt zunächst noch unangetastet und wird nur "reserviert" - in der Foodsoft wird das "verfügbares Guthaben" angezeigt
3.  Mittwoch: 
Der Status der Bestellungen wird eingefroren, FC-Mitglieder können ihre Bestellungen nun nicht mehr ändern, **Listen der Bestellungen** (enthalten nur jeweils gesamte Artikelzahl der Foodcoop) werden **von der Foodsoft an die Lieferantinnen** geschickt
4.  Donnerstag:
FC-Mitglied erstellt in der **Foodsoft mit der Funktion Abholtage Bestelllisten** und druckt sie aus, eine nach Bestellgruppen sortiert, eine nach Artikel sortiert und legt diese Bestelllisten in der Lagerraum 
5.  Donnerstag bis Freitag:
Lieferantinnen liefern bestellte Artikel in den Lagerraum; FC-Mitglied nimmt über **Foodsoft** Bestellungen an und vermerkt **Abweichungen zwischen Bestellung und Lieferungen**
6.  Freitag = **Abholtag**: 
Mitglieder holen ihre bestellten Artikel im Lagerraum ab, die ausgedruckten Bestellliste helfen ihnen dabei,sich ihre Artikel zusammenzusuchen. Im Lagerraum liegen Papierlisten auf, wo die Mitglieder das von ihnen zurückgebrachte Pfand für Leergebinde eintragen, Abweichungen von ihrer Bestellung und dem, was sie bekommen haben, sowie das tatsächliche Gewicht bzw. der tatsächlich Preis bei Artikeln mit variierendem Gewicht. In Zukunft wird es anstelle der Papierlisten eine Foodsoft App geben, über die diese Informationen direkt in die Foodsoft eingegeben werden können.

Parallel dazu laufen noch folgende Vorgänge ab:

1. **Mitglieder laden ihr Foodsoft-Guthaben auf**, indem sie per Banküberweisung unter Verwendung eines in der Foodsoft generierten Zahlungsreferenzcodes Geld an das Bankkonto der Foodsoft überweisen;
    
2. Ein FC-Mitglied mit Ebanking Zugriff auf das Bankkonto importiert regelmäßig z.B. einmal täglich an Wochentagen in der früh, und/oder wenn sie über die Ebanking-App Mitteilungen über neue Kontoeingänge gekommt, die **Buchungsdaten des Bankkontos in die Foodsoft**. Überweisungen der Mitglieder für Guthaben werden dabei über die Zahlunsgreferenzcodes automatisch ihrem Foodsoft-Guthaben gutgeschrieben. 
3. Ein FC-Mitglied überträgt die Papierlisten des Lagerraums in die Foodsoft, indem das Pfand dem Mitglieder Guthaben gutgeschrieben wird, Bestellungen an die tatsächlich erhaltene Mengen angepasst und Differenzbeträge bei Artikeln mit variablen Kosten dem Mitglieder-Guthaben gutgeschrieben oder abgezogen werden.
4. LieferantInnen schicken Rechnungen an die Foodcoop mit ihren Lieferungen, per Post oder per Email; FC-Mitglieder übertragen diese **Rechnungen in die Foodsoft** und kontrollieren, inwieweit das bei den Bestellungen von den Mitglieder-Guthaben abgezogene Geldbträge mit denen der Rechnungen übereinstimmen, und geben sie in der Foodsoft zur Bezahlung frei (sofern auch Punkt 2 schon erledigt ist)
5. Ein FC-Mitglied mit Zugang zum E-Banking des FC-Bankkontos **zahlt freigegebene Rechnungen ein,** indem sie in der Foodsoft Rechnungen aus der Liste der unbezalten Rechnungen auswählt, und in der E-Banking-App die Transaktionen freigibt.
6. Ein FC-Mitglied **rechnet in der Foodsoft abgeschlossene Bestellungen ab**, für die bereits eine Rechnung eingegeben und bezahlt wurde. Damit wird das bis dahin für Bestellungen nur reservierte Guthaben den Mitgliedern endgültig abgezogen, es scheint auf ihrem **Kontoauszug in der Foodsoft** auf.
7. Ein FC-Mitglied bucht monatlich über die **Foodsoft** die **Mitgliedsbeiträge** der Mitglieder von ihrem Guthaben ab.
8. Mitglieder können sich über **Nachrichten in der Foodsoft** austauschen, die sie per Email zugeschickt bekommen, Entscheidungen können über **Umfragen** getroffen werden, anfallende **Aufgaben** werden über die Foodsoft ausgeschrieben und FC-Mitglieder tragen sich dafür ein. 

## Anwendungsvarianten der Foodsoft

Es gibt viele Anwendungsvarianten der Foodsoft, je nachdem, welche der
Funktionen der Foodsoft genutzt bzw. nicht genutzt werden. Damit die
Foodsoft in jedem Fall korrekt eingerichtet und verwendet werden kann,
haben wir im Folgenden versucht, typische Anwendungsfälle aufzulisten. 

|                     |   |   |   |   |
| ------------------- | - | - | - | - |
| Funktion / Variante | 1 | 2 | 3 | 4 |
| Bestellen           | x | x | x | x |
| Guthaben            |   | x | x | x |
| Rechnungen          |   |   | x | x |
| Bankanbindung       |   |   |   | x |

### Variante 1: nur Bestellen

Auch wenn ihr die Foodsoft nur zum Bestellen verwendet, solltet ihr unbedingt eure Bestellungen auch abrechnen (siehe [Bestellung abrechnen](#anchor-64)). Damit sagt ihr der Foodsoft, dass die Bestellung nur mehr historisch relevant ist. Andernfalls taucht sie sowohl bei den Abholtagen, als auch in der Bestellverwaltung auf. Irgendwann werden die Seiten dann aber so lang, dass sie Ewigkeiten zum Laden benötigen.

Sofern ihr die Foodsoft nicht für eure Finanzen verwendet, solltet ihr 

- *Mitglieder manuell abrechnen* unter Administration-\>Einstellungen-\>Finanzen aktivieren. Dadurch gibt es auf den Konten keine Buchungen, wenn ihr die Bestellungen abrechnet.
- Wenn ihr *Minimaler Kontostand* zusätzlich noch auf z.B. *-1000* setzt, dann könnt ihr euch das mit dem „Startgeld“ ersparen. 

### Variante 2: Bestellungen und Guthaben, keine Rechungen

Bei der Abrechnung von Bestellungen wird den Mitgliedern das entsprechende Guthaben von ihren Foodsoft-Konten abgebucht. Dafür ist es nötig, auch eine Rechnung anzulegen. Gedacht ist es so, dass dabei eine digitale Kopie der Rechnung der Lieferantin in der Foodsoft erstellt wird. Das mag nach ein wenig Mehraufwand klingen, ermöglicht aber eine bessere Übersicht und Arbeitsteilung in der Foodcoop. Falls ihr dennoch keine „echten“ Rechnungen anlegen wollt, müsst ihr zumindest eine Pseudo-Rechnung erstellen, um Bestellungen abrechnen zu können. Diese
sollten:

- Der Bestellung zugeordnet sein
- Rechnungsbetrag = Bestellbetrag
- Als bezahlt markiert werden, indem im Feld ein Datum eingetragen wird

### Variante 3: keine Bankanbindung

- Guthaben aus Ebanking manuell in Foodsoft übertragen
- Rechnungen händisch als bezahlt markieren

### Variante 4: Vollnutzung

Wie beschrieben unter *Funktionsüberblick*.

### Optionale Funktionen

Folgende Funktionen können optional teilweise auch deaktiviert werden,
wenn sie nicht benötigt werden, sodass sie gar nicht aufscheinen:

* Nachrichten
* Aufgaben- und Apfelpunktesystem
* Umfragen
* WIKI
* Dokumenteverwaltung

# Menüs für Administration

Mit Administrationsrechten ist das Foodsoft Menü gegenüber den Standard-Rechten (siehe [Benutzerinnenverwaltung](/de/documentation/admin/users)) erweitert:

![menues-admin.gif](/uploads-de/admin_general_menues-admin.gif)


| Menü                | Untermenü | [Berechtigung(en)](/de/documentation/admin/users) |
| ------------------- | --------- | --------------- | 
| Bestellungen | [Bestellverwaltung](/de/documentation/admin/orders) | Bestellungen | 
| Artikel | Lieferantinnen |  | 
| Artikel | Lager |  | 
| Artikel | Kategorien |  | 
| Finanzen | Übersicht | Finanzen | 
| Finanzen | [Bankkonten](/de/documentation/admin/finances/bank-accounts) | Finanzen | 
| Finanzen | [Konten verwalten](/de/documentation/admin/finances/accounts)| Finanzen | 
| Finanzen | [Bestellungen abrechnen](/de/documentation/admin/orders) | Finanzen | 
| Finanzen | [Rechnungen](/de/documentation/admin/finances/) | Finanzen | 
| Adminstration | [Benutzerinnen, Bestellgruppen, Arbeitsgruppen, Nachrichtengruppen](/de/documentation/admin/users) | Admin | 
| Adminstration | [Einstellungen](/de/documentation/admin/settings) | Admin | 

# Foodsoft einrichten

> **Österreich**: Die IG Foodcoops betreibt einen Server, auf dem die Foodsoft installiert ist, und Foodcoops ihre eigene Foodsoft Instanz aktiviert bekommen können. Ihr müsst euch also nicht selbst um einen Server und die Installation der Foodsoft kümmern, obwohl das natürlich auch möglich ist. 
{.is-success}


Wenn ihr dabei seid, eine Foodcoop neu zu gründen, könnt ihr in der [Demo-Instanz](/de/documentation/admin/foodsoft-demo) die Foodsoft zunächst mal ausprobieren. Wenn ihr sicher seid, dass ihr sie verwenden wollt, sind folgende Schritte nötig bzw. empfohlen:


## Notwendige Schritte

1. Auf einem Webserver eine Foodsoft-Instanz installieren bzw. aktivieren
     - [Vorhandenen Server nutzen](/de/documentation/admin/request-foodsoftinstance), auf dem die Foodsoft bereits installiert ist
     - Auf einem eigenen Webserver: [Foodsoft Installation/Setup](/de/documentation/development/first-steps)
1. [Allgemeine Einstellungen](/de/documentation/admin/settings) 
1. [Benutzerinnenverwaltung](/de/documentation/admin/users) BenutzerInnen und Bestellgruppen anlegen, Arbeitsgruppen und Berechtigungen setzen
1. [Lieferantinnen, Artikel und Kategorien anlegen](/de/documentation/admin/suppliers)

## Optionale Schritte

- [Dokumente, Infos und Anleitungen für Foodcoop Mitglieder anlegen](/de/documentation/usage/sharedocuments)
- [Bankkonto mit Foodsoft verbinden](/de/documentation/admin/finances/bank-accounts)
- ...


# Foodsoft verwenden

- [Benutzerinnen und Bestellgruppen anlegen](/de/documentation/admin/users)
- [Lieferantinnen und Artikel anlegen](/de/documentation/admin/suppliers)
- [Lager anlegen](/de/documentation/admin/storage)
- [Bestellungen anlegen](/de/documentation/admin/orders)
- [Mitglieder-Konten für Guthaben](/de/documentation/admin/finances/accounts)
- [Rechnungen anlegen](/de/documentation/admin/finances/invoices)
{.links-list}

## Allgemeine Tipps

- [Demoinstallationen der Foodsoft](/de/documentation/admin/foodsoft-demo) Hier kannst du die Foodsoft testen und etwas ausprobieren, ohne etwas in deiner eigenen Foodsoft kaputt zu machen 
{.links-list}
- [Begriffsklärungen](/de/documentation/admin/terms-definitions) Manche Begriffe in der Foodsoft haben spezielle oder auch mehrfache Bedeutungen
- [Brutto, Netto und Mehrwertsteuer](/de/documentation/admin/finances/value-added-tax) Wie wir als Foodcoop mit Mehrwertsteuer umgehen sollen, und wie Mehrwertsteuer in der Foodsoft berücksichtigt werden kann
- [Foodsoft-Listen](/de/documentation/admin/lists) Allgemeines zum Umgang mit Listen-Darstellungen in der Foodsoft (Artikel, Bestellungen, Rechnungen, ...), die schnell mal etwas unübersichtlich werden können


