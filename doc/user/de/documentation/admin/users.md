---
title: Benutzerinnen-Verwaltung
description: Verwaltung aller Mitglieder, deren Foodsoft-Konten und Bestellgruppen (Menü "Administration" > "Benutzerinnen", "Bestellgruppen", "Arbeitsgruppen", "Nachrichtengruppen")
published: true
date: 2021-10-13T09:47:34.306Z
tags: 
editor: markdown
dateCreated: 2021-04-21T00:39:19.334Z
---


# Übersicht

Menü *Adminstration > Übersicht*

## Neueste Benutzer/innen

> Hier fehlt noch ein Text.
{.is-danger}


## Neueste Gruppen

> Hier fehlt noch ein Text.
{.is-danger}

# Benutzer/innen

Menü *Administration > Benutzer/innen*

## Liste anzeigen: Benutzer/innen verwalten 


> Hier fehlen noch Beschreibungen.
{.is-danger}



### Name 	

### E-Mail 	
Die Benutzerin meldet sich mit ihrer Emailadresse und Passwort in der Foodosft an, solange die [Einstellung](/de/documentation/admin/settings) *Benutzernamen verwenden* inaktiv ist. Weiters wird die Emailadresse für das Versenden von Foodsoft Nachrichten per Email verwendet (siehe [Profileinstellungen: Benachrichtigungen](/de/documentation/usage/profile-ordergroup), [Nachrichten](/de/documentation/usage/communication)). 

### Zugriff auf 	

### Letzte Aktivität 	

### Aktionen

  - Bearbeiten
  - Löschen

### Suchfeld

Zeige nur Benutzerinnen, deren Name den eingegenen Text enthält. 

> Ermöglich keine Suche nach Emailadressen oder Bestellgruppen.
{.is-warning}


### Gelöschte Benutzer anzeigen

> Hier fehlen noch eine Beschreibung.
{.is-danger}

## Neue/n Benutzer/in anlegen

Link *Hier kannst du Benutzer/innen **neu anlegen***, oder blaue Schaltfläche *Neue/n Benutzer/in anlegen*.

> Hier fehlt noch eine Beschreibung.
{.is-danger}

## Details anzeigen

Auf Name der Benutzerin klicken.

### Person (grauer Kasten)
- Mitglied seit
- Name
- E-Mail
- Telefon
- Letzter login
- Letzte Aktivität
- **Zugriff auf**: Berechtigungen, die das Mitglied aufgrund seiner Arbeitsgruppen-Mitgliedschaft hat (siehe Abschnitt Berechtigungen).

### Einstellungen (grauer Kasten)

- Sprache 	
- Telefon ist für Mitglieder sichtbar. 	
- E-Mail ist für Mitglieder sichtbar. 	


### Gruppenabos

- Name und Link zur Bestellgruppe
- Name und Links sonstiger Arbeitsgruppen (falls Mitglied)

### Mögliche Aktionen
  - **Bearbeiten** (siehe unten)
  - **Löschen** (siehe unten)
  - **[Nachricht senden](/de/documentation/usage/communication)**
  - **Als anderer Benutzer anmelden**: Als diese Benutzerin anmelden. So kannst du dich als Administratorin in die Rolle der Benutzerin versetzen, als ob du dich mit ihrem Benutzernamen und Passwort in der Foodosft angemeldet hättest. Zum Beenden aus der Foodsoft abmelden und als Admin neu anmelden.

## Benutzerin bearbeiten

Spalte Aktionen *Bearbeiten* klicken, oder *Details anzeigen (auf Name klicken) > bearbeiten*.

> Hier fehlt noch eine Beschreibung.
{.is-danger}

## Passwort vergessen

Es ist auch für Foodsoft Administratorinnen nicht möglich, die Passwörter von Benutzerinnen nachzusehen, wenn diese es vergessen haben (außer die Administratorin hat es selbst vergeben und kann sich noch erinnern), da die Passwörter in der Foodsoft nur verschlüsselt abgelegt sind. Administratorinnen können in so einem Fall nur das **Passwort neu setzen**.


## Benutzerin löschen

> Hier fehlt noch eine Beschreibung.
{.is-danger}

## CSV Export
Liste aller Benutzerinnen in  [CSV-Tabellenformat](/de/documentation/admin/lists) exportieren.


# Bestellgruppen


## Bestellgruppe erstellen und bearbeiten

> Hier fehlt noch ein Text.
{.is-danger}

**Mitgliedsbeitrag**: negative Zahl eingeben. Siehe eigener Abschnitt “Mitgliedsbeiträge”.

**Pausieren von/bis**: hat nur Notiz-Charakter, d.h. es kann jeweils ein Datum eingegeben werden, es verändert sich dadurch aber nichts für das Mitglied (z.B. kann das Mitglied auch in der Pause Guthaben aufladen und bestellen, und es wird ihm ein Mitgliedsbeitrag verrechnet, wenn dieser nicht während der Pause händisch auf 0 gesetzt wird).

### Mitglieder entfernen aus Bestellgruppe: 
1. Benutzername(n) notieren
2. Benutzer aus Bestellgruppe entfernen 
3. Notierte Benutzer löschen

## Bestellgruppe Details anzeigen

Über
- Administration > Bestellgruppen > Name der Bestellgruppe
- Administration > Benutzer/innen > Benutzerin > Gruppenabos

Es werden nur die folgenden Infos angezeigt:
- Beschreibung:
- Kontakt:
- Adresse:
- Mitglieder: ohne Verlinkung zu den einzelnen Mitgliedern. Diese müssen über *Adminstration > Benutzer/innen* aufgerufen werden.

Die Felder *Mitgliedsbeitrag* und *(Letzte) Pause* werden nur unter *Bearbeiten* angezeigt.

Mögliche Aktionen:
- Bearbeiten (siehe oben)
- Löschen (siehe unten)
- [Nachricht senden](/de/documentation/usage/communication)


## Bestellgruppe löschen

> Besser nicht löschen, wenn du dir nicht sicher bist - es gibt keine Undo-Funktion! 
{.is-danger}

> Hier fehlt noch ein Text. 
{.is-danger}

Kontoauszug und Kontostand einer gelöschten Bestellgruppe anzeigen:
siehe [*Finanzen > Kontostand abfragen*](/de/documentation/admin/finances/accounts).

# Berechtigungen

## Berechtigungen setzen

Berechtigungen können entweder über *Adminstration \> Arbeitsgruppen* oder pauschal für alle Mitglieder über *Administration \> Einstellungen \> Sicherheit \> Zugriff auf* gesetzt werden. Es ist nicht möglich, Berechtigungen nur für einzelne Mitglieder zu setzen, sondern es ist immer erforderlich, eine Arbeitsgruppe anzulegen, dieser Berechtigungen zu vergeben, und anschließend dieser Arbeitsgruppe Mitglieder zuzuweisen. Eine Arbeitsgruppe kann kein, eines oder beliebig viele Mitglieder enthalten. Mitglieder können in beliebig vielen Arbeitsgruppen Mitglied sein. Beispiele siehe ...

## Berechtigungen anzeigen

- *Adminstration \> Arbeitsgruppen \> Arbeitsgruppe* auswählen, um Mitglieder anzuzeigen
- *Adminstration \> Benutzer/innen*: für jede Benutzerin werden die Berechtigungen durch entsprechende Symbole angezeigt. Für die Bedeutung der Symbole mit der Maus über das Symbol fahren, es wird der entsprechene Text eingeblendet.

## Arten von Berechtigungen

### Lieferanten

Menü *Artikel* wird angezeigt, kann Lieferanten, Lager und Lagerartikel einsehen und bearbeiten, jedoch nicht die Artikel der Lieferanten einsehen: Link auf Artikel bei Lieferanten scheint zwar auf, aber beim Anklicken kommt Hinweis: keine Berechtigung

### Artikeldatenbank (Artikel)

Wird als Berechtigung „Artikel“ angezeigt, beim Einstellen heißt die Berechtigung „Artikeldatenbank“. Menü *Artikel* wird angezeigt, alle Unterpunkte können eingesehen und bearbeitet werden, auch *Lieferanten* (schließt Berechtigung Lieferanten mit ein).

...


### Bestellverwaltung (Bestellung)

Wird als Berechtigung „Bestellung“ angezeigt, beim Einstellen heißt die Berechtigung „Bestellverwaltung“.

Kann Bestellungen anlegen, bearbeiten und in Empfang nehmen.

Achtung, für das Anlegen einer Lagerbestellung ist zumindest die Berechtigung „Lieferanten“ erforderlich, oder „Artikel(datenbank)“.

### Abholtage

Mitglieder mit Abholtage Berechtigung können im Menü *Bestellungen > Abholtage* sehen. Dort können sie bei der jeweiligen Bestellung auf  *Download* drücken und z.B. Gruppen PDF wählen. 

Freischalten der Funktion Abholtage:
- Es gibt unter *Administration > Arbeitsgruppen* die Möglichkeit, einer oder mehreren Arbeitsgruppen die Berechtigung Abholtage zu erteilen.  
- Alternativ kann die Berechtigung über *Administration > Einstellungen > Sicherheit > Jedes Mitglied der Foodcoop hat automatisch Zugriff auf folgende Bereiche* die Berechtigung "Abholtage" auch pauschal für alle Mitglieder gesetzt werden.


### Finanzen

Zeigt das gesamte Menü *Finanzen* an, schließt das Untermenü *Rechnungen* mit ein.

Berechtigt zu:
- Foodsoft Transaktionen erstellen
- Importiertes Bankkonto anzeigen
- Bestellungen abrechnen


### Rechnungen

Zeigt den Menüpunkt *Finanzen > Rechnungen* an. Ohne die zusätzliche Berechtigung „Finanzen“ wird sonst kein Menüpunkt des Finanzen-Menüs angezeigt.

Rechnungen zu Bestellungen können angelegt werden, aber Bestellungen können nicht angepasst oder abgerechnet werden.

### Administration

Zeigt das Menü „Administration“ an.

Berechtigt zu:
- Mitgliederverwaltung
  - Mitglieder anlegen und löschen
  - Mitglieder Telefon und Emaildaten unter Foodcoop \> Mitglieder anzeigen, auch wenn diese in ihrem Profil unter Privatsphäre „sichtbar“ nicht angewählt haben
  - Bestellgruppen anlegen und löschen
  - Arbeitsgruppen anlegen und bearbeiten
  - Nachrichtengruppen anlegen und bearbeiten

- Einstellungen in der Foodsoft vornehmen
  - Finanzen: Transaktionsklassen und -typen erstellen und bearbeiten
  - Links
  - Einstellungen: 

> Dieses Berechtigung sollte aufgeteilt werden in „Mitgliederverwaltung“ und „Einstellungen“, siehe auch: [https://github.com/foodcoops/foodsoft/issues/825](https://github.com/foodcoops/foodsoft/issues/825)
{.is-danger}


## Beispiele für typische Aufgaben und Berechtigungen
- Regelmäßig wiederkehrende **Bestellungen anlegen**: 
  - Bestellungen 
  - Für Lagerbestellungen: Lieferanten oder Artikeldatenbank
- **Lieferantinnen Betreuung** durch FC Mitglieder: Lieferantin und Artikel anlegen/aktualisieren, Bestellungen anlegen und annehmen (anpassen an tatsächlich gelieferte Mengen), Rechnungen der Lieferantin in die Foodsoft eingeben
  - Lieferanten, Artikel, Bestellung, Abholtage, Rechnungen 
- **Produzentinnen**, die selber Zugriff auf die Foodsoft haben sollen, um dort ihre Artikel zu aktualisieren und Bestellungen anzulegen: 
  - Lieferanten, Artikel, Bestellung
- **Bestellungen abrechnen**: Bestellungen anpassen an tatsächlich gelieferte Mengen, Ausgleichstransaktionen bei abweichenden Gewichten/Preisen
  - Finanzen
- **Mitglieder Betreuung**
  - Administration: Mitglieder und Bestellgruppen anlegen und verwalten
  - Finanzen: Guthaben manuell aufladen bei Neumitgliedern, Guthaben entleeren bei Austritten, Mitgliedsbeiträge abbuchen
- **Finanzteam** mit Zugriff aus Foodcoop-Bankkonto
  - Finanzen: Bankkontodaten importieren, Rechnungen bezahlen,
        manuelle Transkationen Guthaben Bestellgruppen 

# Arbeitsgruppen

- Mitglieder zu Arbeitsgruppen können nur durch Administratorinnen hinzugefügt werden. 
- Mitglieder können selbständig Arbeitsgruppen verlassen ([Profil](/de/documentation/usage/profile-ordergroup))
- Benutzerrechte (Berechtigungen) können nur für Arbeitsgruppen vergeben werden
- [Nachrichten](/de/documentation/usage/communication) Verfassen an Mitglieder möglich

> Hier fehlt noch ein Text.
{.is-danger}


# Nachrichtengruppen

- Mitglieder können selbständig Arbeitsgruppen beitreten und sie verlassen unter [*Foodcoop > Nachrichten > Nachrichtengruppen beitreten*](/de/documentation/usage/communication)
- [Nachrichten](/de/documentation/usage/communication) Verfassen an Mitglieder möglich

> Hier fehlt noch ein Text.
{.is-danger}

