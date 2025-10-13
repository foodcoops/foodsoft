---
title: Datenbank - phpMyAdmin
description: Welche verstecken Features der Zugriff auf die Foodsoft-Datenbank bietet
published: true
date: 2025-10-07T23:09:47.024Z
tags: 
editor: markdown
dateCreated: 2023-04-09T02:10:13.914Z
---

# Datenbankzugriff via phpMyAdmin

> Über das Tool phpMyAdmin kannst du einfach im Browser auf die Datenbank deiner Foodsoft-Instanz zugreifen und Daten auslesen/verändern.
{.is-success}

> Dies ist für einige versteckte Features, für die es noch kein Menü in der Foodsoft-Benutzeroberfläche gibt, die einzige Möglichkeit sie zu aktivieren.
In anderen Fällen kann es einfach viel praktischer sein, als z.B. eine Reihe von Daten händisch über die Foodsoft-Benutzeroberfläche zu bearbeiten bzw. nachzuschlagen.
{.is-info}

> Für viele Zwecke brauchst du dabei gar keine speziellen SQL-Kenntnisse.
{.is-success}

> Sei aber äußerst vorsichtig, denn du kannst mit diesem Tool deine Foodsoft-Instanz zerstören bzw. darin viel kaputtmachen!
Sei daher behutsam mit dem Einsatz von phpMyAdmin.
{.is-warning}

> Den Zugang zu eurer Foodsoft-Datenbank musst du zunächst beim Host deiner Foodsoft-Instanz (z.B. IG FoodCoops in Österreich) anfordern.
Anschließend kannst du im Browser phpMyAdmin öffnen (die Adresse variiert je nach Installation).
{.is-info}


# Einführung in phpMyAdmin
## Navigation

In der linken Seitenleiste siehst du, für welche Foodsoft-Instanzen du Zugriffsrechte hast.

![grafik.png](/uploads-de//grafik.png)

Für jede Foodsoft-Instanz ist eine Reihe an Tabellen gespeichert:

![db_tabellen.png](/uploads-de//db_tabellen.png)

In jeder Tabelle wird eine Reihe an Datensätzen gespeichert, beispielsweise sämtliche Artikel von allen Lieferantinnen.

![db_datensaetze.png](/uploads-de//db_datensaetze.png)

## Datensätze bearbeiten

Um einen Wert in einem Datensatz zu bearbeiten, einfach auf den Wert doppelklicken:

![db_inline.png](/uploads-de//db_inline.png)

Bei mehrzeiligen Werten kann es jedoch mühsam sein, sie "inline" zu bearbeiten. Dafür links auf "Bearbeiten" klicken. Im folgenden Menü können die Werte in einem größeren Feld bearbeitet werden.

![db_bearbeiten.png](/uploads-de//db_bearbeiten.png)

Danach musst die Änderungen am Datensatz noch speichern, indem du unten auf OK klickst:

![db_speichern.png](/uploads-de//db_speichern.png)

Oder du klickst im Browser einfach auf Zurück oder in der oberen Leiste auf Anzeigen, um die Bearbeitung abzubrechen.

> Verändere nicht die `id` eines Datensatzes, denn andere Datensätze verweisen auf diesen mittels dieser ID, außerdem dürfen zwei Datensätze in einer Tabelle nicht die gleiche `id` haben.
{.is-warning}

## Weitere Funktionen

Mit den entsprechenden Kenntnissen lassen sich auch SQL-Befehle und viele Funktionen anwenden. Diese brauchst du jedoch für die folgenden Anleitungen nicht.

# Benutzerdefinierte Felder (custom fields)

Mit diesem Feature kannst du zusätzliche Felder für
- Benutzerinnen
- Bestellgruppen
- Arbeitsgruppen
- Lieferantinnen (speichern funktioniert nicht)
- Rechnungen

anlegen, in die dann über die Benutzeroberfläche Daten eingetragen werden können.

> Die benutzerdefinierten Felder werden nicht in den Anzeige-Menüs aufgelistet, sondern nur in den Bearbeiten- bzw. Erstellen-Menüs.
{.is-danger}

Benutzerdefinierte Felder werden zusammen mit den Standard-Felder angezeigt:

![cf_bestellgruppe.drawio.png](/uploads-de//cf_bestellgruppe.drawio.png)

> Benutzerdefinierte Felder für Lieferantinnen werden zwar angezeigt, Eingaben werden jedoch nicht gespeichert: [Issue 952](https://github.com/foodcoops/foodsoft/issues/952)
{.is-danger}

## Felder konfigurieren

### Settings-Tabelle öffnen

Die Konfiguration der benutzerdefinierten Felder wird in einem einzigen Datensatz in der Tabelle settings gespeichert.

![db_settings.png](/uploads-de//db_settings.png)

### Datensatz für benutzerdefinierte Felder finden

Stelle die Anzahl der Datensätze auf das Maximum und gib bei "Zeilen filtern" `.custom` ein, dann sollte ein Datensatz mit var = `foodcoop.<name>.custom_fields` erscheinen. Wenn nichts erscheint, probiere auf Seite 2, 3 ... zu blättern, bis er erscheint. Sollte er nicht existieren, musst du einen neuen Datensatz erstellen.

![db_customfields.png](/uploads-de//db_customfields.png)

### Bearbeiten

Klicke auf **Bearbeiten** und verändere den Wert unter Value. Beispiel:

![db_cf_bearbeiten-.png](/uploads-de//db_cf_bearbeiten-.png)

### Syntax
#### Felder für unterschiedliche Objekte

So können jeweils beliebig viele Felder für Benutzerinnen, Bestellgruppen, Arbeitsgruppen, Lieferantinnen und Rechnungen konfiguriert werden.

```
--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
user:
  - name: user_field
    label: Benutzerinnen-Feld
ordergroup:
  - name: ordergroup_field
    label: Bestellgruppen-Feld
workgroup:
  - name: workgroup_field
    label: Arbeitsgruppen-Feld
supplier:
  - name: supplier_field
    label: Lieferantinnen-Feld
invoice:
  - name: invoice_field
    label: Rechnungen-Feld
```

#### Weitere Optionen

Für Felder gibt es noch weitere hilfreiche Optionen:

```
--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
user:
  - name: test_field
    label: Testfeld
    hint: Ein Hinweis, der unterhalb des Eingabefeldes angezeigt wird.
    placeholder: 'Hinweis innerhalb des Eingabefeldes'
  - name: text_field
    label: Textfeld
    as: text
  - name: password_field
    label: Passwort-Feld
    as: password
  - name: float_number_field
    label: Fließkommazahl
    as: float
  - name: date_field
    label: Datumsfeld
    as: date
    html5: true
```

Das sieht dann so aus:

![cf_beispiel.png](/uploads-de//cf_beispiel.png)

> Eine Liste an möglichen Optionen findest du [hier](https://github.com/heartcombo/simple_form#available-input-types-and-defaults-for-each-column-type), jedoch funktionieren nicht all diese Datentypen ohne weiteres (z.B. werden die Eingaben nicht gespeichert).
Die oben aufgelisten Datentypen sind erfolgreich getestet worden.
{.is-info}

#### Anwendung auf Kontotransaktionen (z.B. für Mitgliedsbeitrag)

```
--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
ordergroup:
  - name: membership_fee
    label: Mitgliedsbeitrag
    hint: Als negative Zahl eintragen (z.B. -4 oder -4,5 oder -4.5)
    financial_transaction_source: true
```
    
Die letzte Zeile bewirkt, dass im Menü `Neue Überweisungen eingeben` folgender Button erscheint:

![mb_hinzufuegen.png](/uploads-de//mb_hinzufuegen.png)

> Dadurch werden die Bestellgruppen hinzugefügt und jeweils der Wert, der als Mitgliedsbeitrag gespeichert ist, direkt als Betrag eingefügt.
{.is-success}

> Da ein positiver Betrag der Bestellgruppe gutgeschrieben wird, ist es zum Einziehen von Mitgliedsbeiträgen notwendig das Feld mit einer negativen Zahl auszufüllen. Da dies kontraintuitiv ist, ist es ratsam per Hinweis (hint) darauf hinzuweisen.
{.is-warning}

> Der Mitgliedsbeitrag kann so je Bestellgruppe individuell festgelegt werden - z.B. je nach dem, aus wie vielen Personen eine Bestellgruppe besteht oder welche Einkommensverhältnisse vorherrschen.
{.is-success}

> Es können auch mehrere benutzerdefinierte Felder als financial_transaction_source definiert werden, dann erscheinen mehrere solche Buttons ("Alle Bestellgruppen mit ... hinzufügen") nebeneinander.
{.is-success}

Die empfohlene Vorgehensweise für das Verwalten von Mitgliedsbeiträgen über die Foodsoft ist also:
1. Mitgliedsbeitrag-Feld konfigurieren
2. Höhe bzw. Berechnungsgrundlage für den Mitgliedsbeitrag sowie auf welchen Zeitraum er sich bezieht, überlegen
3. Jeweiligen Mitgliedsbeitrag bei Bestellgruppen eintragen (Achtung, dies geht nur über die Administration, kann also nicht von allen Bestellgruppen selbst gemacht werden)
4. [Kontotransaktionsklasse & -typ für Mitgliedsbeitrag einrichten](https://docs.foodcoops.net/de/documentation/admin/finances/accounts) (kann auch vorher geschehen)
5. Bestellgruppen laden ihren Mitgliedsbeitrag auf (wie Guthaben), können also beliebig im Voraus oder nur für die nächste Einziehung einzahlen
6. Ein Mitglied zieht den Mitgliedsbeitrag z.B. jeden Monat/Quartal ein - dabei kann es passieren, dass Bestellgruppen mit ihrem "Mitgliedsbeitrag-Guthaben" ins Minus rutschen und erinnert werden müssen es wieder einzuzahlen.

# Beispiele für Datenbank-Operationen
## Rechnungen ohne Anhang finden

Für FoodCoops mit digitaler Buchführung (d.h. alle Rechnungen werden digital per Foodsoft gespeichert) wurde nach einer Möglichkeit gesucht herauszufinden, welche Rechnungen keinen Anhang haben, z.B. weil er beim Anlegen vergessen wurde hochzuladen. In der Foodsoft müsste man dafür jede Rechnung einzeln anklicken, da in der Rechnungsliste nicht angezeigt wird, ob ein Anhang existiert.

Mit einem Datenbankzugang (phpMyAdmin) lässt sich dies per SQL-Abfrage ermitteln.

Wähle dazu in der Liste der Datenbanken deine Foodsoft aus uns anschließend auf den Reiter SQL:
![sql_reiter.png](/uploads-de//sql_reiter.png)

Kopiere folgende SQL-Abfrage und füge sie ein:

```
SELECT i.id, i.number, i.date, i.paid_on, i.amount
FROM   `invoices` i LEFT OUTER JOIN `active_storage_attachments` a ON i.id = a.record_id
WHERE  a.record_id IS NULL
ORDER  BY i.id DESC;
```

Um die Abfrage im phpMyAdmin zu speichern, gib ihr einen Namen:
![sql_abfrage_speichern.png](/uploads-de/sql_abfrage_speichern.png)

Klicke auf den Button **OK**, um die Abfrage auszuführen.

Anschließend werden die Rechnungen ohne Anhang aufgelistet (zuletzt erstellte zuerst).

Um eine Rechnung in der Foodsoft wiederzufinden, rufe dort eine beliebige Rechnung auf und ersetze die Zahl hinter dem letzten `/` mit der entsprechenden `id`, z.B.:
`.../deine-foodcoop/finance/invoices/123`

## Finanzlinks von Transaktionen und Rechnungen deaktivieren

Jede Foodsoft-Transaktion sollte idealerweise mit einer anderen Transaktion verlinkt sein, z.B. eine Guthaben Aufladung mit der Bank-Transaktion oder eine Guthaben Abbuchung für eine Bestellung mit einer Foodccop-Buchung. Wenn das nicht von Anfang an gemacht wurde, gibt es viele Transaktionen, die nicht verlinkt sind. Bei Auswahllisten beim Erstellen eines Finanzlinks werden alle angezeigt, denen nichts zugeordnet ist, und das sind dann oft sehr, sehr viele. Damit die alten nicht mehr angezeigt werden, kann die Finanzlink ID von älteren Transaktionen von NULL auf -1 gesetzt werden:  

```
UPDATE `financial_transactions` 
SET `financial_link_id`=-1 
WHERE `financial_link_id` IS NULL 
AND `note` LIKE 'Bestellung:%';
```

Das setzt zum Beispiel für alle Abrechnungen von Bestellungen die Finanzlink IDs auf -1, die noch nicht verlinkt sind - in früheren Foodsoft Versionen wurden die Abrechnungstransaktionen noch nicht über einen Finanzlink verlinkt. 

```
UPDATE `invoices` 
SET `financial_link_id`=-1 
WHERE `financial_link_id` IS NULL 
AND `id`<= 1782;
```

Das setzt bei allen Rechnungen ohne Finanzlink mit ID <= 1782 die Finanzlink ID auf -1. Diese Rechnungen scheinen dann beim Hinzufügen einer Rechnung bei einem Finanzlink nicht mehr auf. 

## Unbenutzte Lagerartikel entfernen
Alle Lagerartikel "löschen", wo Lagerstand 0 ist:
```

UPDATE `articles` 
SET `deleted_at` = '2025-08-12 11:00:00' 
WHERE type="StockArticle"  
AND quantity=0 
AND deleted_at IS NULL;
```
Die Artikel werden nicht gelöscht, es wird nur im Feld  *deleted_at* ein Datum eingetragen, wodurch die Artikel in der Foodsoft nicht mehr aufscheinen. Wenn statt dem Datum wieder NULL eingetragen wird, ist der Artikel wieder sichtbar. Wenn über die Foodsoft ein Artikel gelöscht wird, passiert das Gleiche und der Artikel ist immer noch in der Datenbank.

## Status von Bestellungen ändern

Bedeutung des *state* Felds in der Tabelle *orders*:
- `open`: es kann bestellt werden
- `finished`: es kann nicht mehr bestellt werden, aber die Bestellung ist noch nicht abgerechnet
- `received` 	detto, aber	Bestellung wurde in Empfang genommen
- `closed`: die Bestellung ist abgerechnet

> Wenn der Status einer Bestellung in der Datenbank geändert wird, werden die Aktionen, die in der Foodsoft beim Ändern stattfinden, nicht durchgeführt oder wieder rückgängig gemacht, also zum Beispiel: eine Bestellung, die bereits beendet und an die Lieferantin verschickt wurde, enthält nach dem erneuten Öffnen und wieder Beenden auch die Bestellungen, die schon bei der Lieferantin bestellt wurden; wenn der Status in der Datenbank von `open` auf `finished` gesetzt wird, wird die Bestellung nicht automatisch versendet; wenn eine Bestellung bereits abgerechnet wurde, werden die entsprechenden Kontotransaktionen beim Ändern von `closed` auf `finished` nicht automatisch rückgängig gemacht (das muss manuell erledigt werden, wenn gewünscht); wenn der Status einer Bestellung von `finished` auf `closed` gesetzt wird, werden - anders wie beim Abrechnen in der Foodsoft - die entsprechenden Kontotransaktionen nicht durchgeführt.
{.is-warning}

Beispiel:  Status der Bestellungen bis ID 999 von *beendet* auf *abgerechnet* setzen (ohne dass entsprechende Transaktionen durchgefühert werden):
```
UPDATE `orders` 
SET state = 'closed' 
WHERE id <= 999; 
```


Beispiel:  Status der Bestellungen mit bestimmten IDs von *abgerechnet* auf *beendet* zurücksetzen (ohne dass entsprechende Transaktionen rückgängig gemacht werden):
```
UPDATE `orders` 
SET state = 'finished' 
WHERE id IN (1775, 1781, 1801, 1811, 1805, 1816, 1821, 1828, 1825, 1832); 
```