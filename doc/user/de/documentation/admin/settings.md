---
title: Einstellungen
description:  Erklärung zu globalen/administrativen Einstellungen der Foodsoft
published: true
date: 2021-10-07T18:34:41.218Z
tags: 
editor: markdown
dateCreated: 2021-04-21T00:20:52.701Z
---

# BenutzerInnen, Bestell-, Arbeits- und Nachrichtengruppen

Siehe [Benutzerinnenverwaltung](/de/documentation/admin/users).

# E-Mail Probleme

Wenn Emails an Mitglieder oder Lierantinnen nicht zugestellt werden können, legt die Foodsoft hier einen Eintrag an. 

# Finanzen


## Kontotransaktionsklassen und -typen

> Hier fehlt noch ein Text.
> {.is-danger}

Siehe auch  [Konten](/de/documentation/admin/finances/accounts).


## Bankkonten und Gateways

> Hier fehlt noch ein Text.
> {.is-danger}

Siehe auch [Bankkonto](/de/documentation/admin/finances/bank-accounts).


# Links

Links im Foodsoft-Menü "Links" verwalten.

![links-menue.png](/uploads-de/admin_settings_links-menue.png)

## Beispiel
![admin_settings_links-example.png](/uploads-de/admin_settings_links-example.png)

# Einstellungen

> Hier fehlt noch eine detaillierte Beschreibung der einzelnen Einstellungen.
{.is-danger}

## Foodcoop

- Name
- Straße
- Postleitzahl
- Stadt
- Land
- E-Mail
- Telefon
- Webseite


## Finanzen

- Foodcoop Marge
- Mehrwertsteuer

- Minimaler Kontostand: minimal erforderliches verfügbares Guthaben(?), um bestellen zu können; leer = Null
- Mitglieder manuell abrechnen
- IBAN verwenden
- Selbstbedienung verwenden
- Bestellschema
- Kistenauffüllen 
- Bestellschluss
- Kistenauffüllphase


## Aufgaben

- Wiederkehrende Aufgaben
- Apfelpunkte verwenden

## Nachrichten

- E-Mails versenden
- Absenderadresse
- Antwortadresse
- Nachrichten
- Mailingliste
- Mailingliste anmelden


## Layout

- Fußzeile Webseite
- Angepasstes CSS
- PDF-Dokumente
  - Schriftgrösse
  - Seitenformat
  - Seitenwechsel
  - Jede Bestellgruppe auf eine eigene Seite bringen
  - Jeden Artikel auf eine eigene Seite bringen

## Sprache

- Standardsprache
- Browsersprache ignorieren
- Zeitzone
- Währung
  - Leerzeichen hinzufügen 

## Sicherheit

- Zugriff auf: jedes Mitglied der Foodcoop hat automatisch Zugriff auf folgende Bereiche. Siehe Berechtigungen
- Api Titl:e de.config.keys.api\_key

## Sonstiges

- Umfragen aktivieren
- Wiki verwenden
- Benutzernamen verwenden
- Bestelltoleranz maximal ausnutzen, um möglichst große Mengen zu bestellen
- Verteilungs-Strategie
- Einladungen deaktivieren
- URL Dokumentation
- Code für Websiteanalysetool
- Dokumente verwenden
  - Erlaubte Endungen
  - Drucker verwenden

## Liste

Alle Einstellungen gemeinsam in einer Liste dargestellt


## Apps


# Login- und Startseite

## Adaptierung der Foodsoft-Loginseite

Die Login-Seite der Foodsoft kann individuell an deine Foodsoft angepast werden, indem du eine Wiki-Seite mit dem Titel **Public\_frontpage** erstellst. Der Inhalt dieser Wiki-Seite könnte z.B. sein:


```
=== Foodcoop XY ===

Bitte melde dich mit deinen Zugangsdaten an, um Zugang 
zu unserer Foodsoft zu erhalten. 

Der Zugang ist nur für Mitglieder der Foodcoop XY möglich. 

Wenn du noch kein Mitglied bist, kannst du über 
...(Weblink)... Probemitglied werden  und damit einen Zugang bekommen.
```
## Adaptierung des Dashboards (Startseite)

Erstelle eine Wiki-Seite mit dem Titel **Dashboard**, die als erster Block am Dashboard angezeigt wird. 

Damit diese Wiki-Seite leichter aufgefunden und bearbeitet werden kann, kannst du am Ende der Seite z.B. folgenden Text einfügen (bitte Link entsprechend deiner Foodcoop anpasssen): 

```
<p style="font-size:8px">
''Text veränderbar über die Wiki-Seite 
[https://app.foodcoops.at/...(foodcoop name).../wiki/Dashboard Dashboard]''
</p>

