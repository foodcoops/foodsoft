---
title: Lieferantinnen und Artikel
description: Verwaltung von Lieferantinnen und Artikeln
published: true
date: 2023-01-27T13:08:29.461Z
tags: 
editor: markdown
dateCreated: 2021-04-20T21:50:56.992Z
---

In der Foodsoft werden ProduzentInnen und LieferantInnen generell als „Lieferantin“ oder „Lieferanten“ bezeichnet, und Produkte als "Artikel". Übergreifend über Lieferantinnen können Artikeln Kategorien (z.B. Gemüse, Saft, Obst, ...) zugeordnet werden.

# Lieferanten

"Lieferanten" können Produzierende, aber auch z.B. Handelnde oder Großhandelnde sein. 


## Anlegen

Artikel \> Lieferanten/Artikel \> Neue Lieferantin anlegen

Weitere Infos siehe "Bearbeiten".

> Da eine Lieferantin nur mit Schwierigkeiten wieder gelöscht werden kann (siehe unten), bitte nur Lieferantinnen anlegen, wenn das auch wirklich benötigt wird. Zum Herumprobieren am Besten eine [Foodsoft Demoversion](/de/documentation/admin/foodsoft-demo) verwenden.
{.is-warning}

![lieferantin-neu.png](/uploads-de/admin_suppliers_lieferantin-neu.png)


## Bearbeiten

Artikel \> Lieferanten/Artikel \> Name anklicken

### Name

> Empfehlung: unabhängig von der offiziellen Bezeichnung den Eigennamen an erste Stelle stellen, also z.B. "Adam Biohof" statt "Biohof Adam". Das erleichtert es später, Lieferantinnen in alphabetisch sortierten Listen schneller zu finden.
{.is-info}

### Adresse

Postadresse der Lieferantin: Straße, Hausnummer, Postleitzahl, Ort.

### Telefon, Telefon 2 und Fax

Telefonnummer(n) der Lieferantin und - falls vorhanden -  [Fax](https://de.wikipedia.org/wiki/Fax)-Nummer

### Website

Url (Link) zur Homepage der Lieferantin, beginnend mit `http://` oder  `https://`. Nur sichtbar mit entsprechender Berechtigung, daher nicht geeignet als allgemeine Info für Bestellerinnen.


### Kategorie (supplier category)

- **Konsum**: Lieferantinnen, deren Rechnungen von den Bestellguthaben der Mitglieder bezahlt werden, also z.B. Gemüsebäurin, Käserei, ...
- **Betriebskosten**: Lieferantin, deren Rechnungen vom Verein bzw. den Mitgliedsbeiträgen bezahlt werden, wie z.B. Lagerraummiete, Strom, …
- **Sonstiges**: Anschaffungen des Vereins wie Putzmittel, Ausstattung Lagerraum, …

Die Auswahl der Kategorie wirkt sich nur in der buchhalterischen Darstellung der Bilanz aus (Finanzen \> Übersicht \> Bericht erstellen).

### IBAN

Die Eingabe der IBAN des Bankkontos der Produzentin ist dann erforderlich, wenn das Foodcoop Bankkonto mit der Foodsoft verknüpft wird, und Rechnungen automatisch als bezahlt markiert werden sollen (siehe unten).

- Einmaliges Aktivieren des Feldes IBAN unter Administration \> Einstellungen \> Finanzen \> IBAN verwenden
- Lieferantin: Eingabe des IBAN ohne Leerzeichen erforderlich
- Eine Prüfung der IBAN erfolgt nicht, das heißt es ist möglich, eine ungültige IBAN einzugeben. Empfehlung daher: IBAN prüfen z.B. über [*https://www.iban-bic-rechner.at/iban-validator.php*](https://www.iban-bic-rechner.at/iban-validator.php) (copy-paste)


### Mindestbestellmenge

Dieses Feld kann auf zwei Arten benutzt werden:
- als Text, der beim Bestellen angezeigt wird
- als Zahl für einen Geldbetrag, der einen Mindestbestellwert darstellt.  Bei Bestellung wird dann dieser Wert und der aktuelle Bestellwert von allen Bestellgruppen angezeigt. Bei Anlegen der Bestellung kann die Option “... nur wenn Mindestbestellwert erreicht ist” ausgewählt werden.

> Bei der Angabe einer Zahl kann zusätzlich hinter der Zahl eine Währung bzw. ein Währungssymbol  angegeben werden, z.B. "40 €". Getestet von Mirko 2022-10-28, jedoch keine Garantie, dass es so bleibt.
{.is-success}


> Eine automatische Mindest-Stückzahl nicht möglich, daher in Geldwert umrechnen bzw. mit Lieferantin stattdessen Euro-Wert vereinbaren. 
{.is-info}



## Lieferantin löschen

> Die Funktion „Löschen“ sollte mit besonderer Vorsicht verwendet werden! Besser Lieferantinnen umbenennen, statt neue zu erstellen und alte zu löschen.
{.is-warning}

Da mit einer Lieferantin Bestellungen und Rechnungen verknüpft sein können, wird eine Lieferantin nicht wirklich gelöscht. Sie bleibt in der Datenbank erhalten und verschwindet lediglich aus den Lieferanten Listen, mit Ausnahme der Liste unter Finanzen \> Rechnung erstellen, wo die Lieferantin mit einem † markiert sichtbar bleibt. Die Lieferantin kann nicht mehr bearbeitet werden, es ist auch nicht möglich, eine neue Lieferantin mit dem selben Namen oder der selben IBAN zu erstellen. 

> Ihr könnt Lieferantinnen, bei denen ihr momentan nicht (mehr) bestellt, z.B. mit "ZZ" am Anfang umbenennen, sodass sie in den Auswahllisten ganz am Ende stehen und es klar ist, dass sie ruhend gestellt sind. So stören sie in der Liste nicht so, und bleiben trotzdem bearbeitbar/reaktivierbar.
{.is-info}

> [*https://github.com/foodcoops/foodsoft/issues/832*](https://github.com/foodcoops/foodsoft/issues/832)
{.is-danger}



# Artikel

## Artikelfelder (Stammdaten)

Jeder Artikel in der Foodsoft, hat folgende Variablen/Felder, notwendige sind mit * vermerkt:

* ***Artikel ist verfügbar?** (Ja/Nein)
* ***Name** (Text, frei wählbar)
* ***Einheit** (Text, frei wählbar)
* **Notiz** (Text, frei wählbar)
* ***Kategorie** (Name erstellter Kategorie)
* ***Nettopreis** (Kommazahl mit ".") und **MWSt** (Prozent) 
* ***Pfand** (Kommazahl mit ".")
* **Endpreis** (Kommazahl mit ".")
* **Herkunft** (Text)
* **Produzent** (Text)
* **Bestellnummer** (Text)

Details zu den Feldern, Hinweise zur Verwendung und derzeitige technische Einschränkungen, werden in den folgenden Kapiteln erläutert.

### Artikel ist verfügbar?

Falls Artikel nicht verfügbar ist, z.B. weil außerhalb der Saison, Häckchen entfernen. Artikel erscheint dann grau in der Artikelliste und wird in Bestellungen nicht aufgenommen.


### Name

Der Name des Artikels muss aus 4 bis 60 Zeichen bestehen.

> Es dürfen bei einer Lieferantin **nicht zwei Artikel mit dem selben Namen** vorkommen. Wenn es z.B. den selben Artikel in unterschiedlichen Größen gibt, muss der Name indivuell verschieden sein, beispielsweise „Roggen klein“ für 1 kg, Roggen groß“ für 5 kg
{.is-warning}


### Einheit und Gebinde

Unter Einheit gibt es zwei Felder: `Gebindegröße` x `Einheit`

Die **Bezeichnung der Einheit** kann frei gewählt werden und muss aus  1 bis 15 Zeichen bestehen, z.B.:
- `500 g`
- `1 L`
- `Flasche`
- `Packung`
- `Stück`


Bestellmengen erfolgen immer in Einser-Schritten der Einheit.

Die Zahl vor der Einheit ist die Mindestmenge bzw. **Gebindegröße**. Sie bestimmt, wieviel Einheiten mindestens bestellt werden müssen, z.B. 6 Gläser in einem Karton, wenn nur ganze Kartons bestellt werden können. Wenn Einheiten einzeln bestellt werden können, 1 eintragen.

> Hier fehlt ein Beschreibung bzw. Link darauf für Mindestmengen und Toleranzen, Einstellungen dazu, was passiert in welchem Fall, wie werden die Artikel aufgeteilt?
{.is-danger}


![prod-artikel-mindestbestellmenge.png](/uploads-de/admin_suppliers_prod-artikel-mindestbestellmenge.png)

> Die Einheit, rechts der Markierung, gibt die Mengen an, in der Bestellt werden kann.
>
> **Beispiel (entspricht Bild oben)**
> 
> Mindestbestellmenge 6 Einheiten je 500g, Bestelleinheiten jeweils 500g KG:
> 
> "Links"  -> 6
> 
> "Rechts" -> 500g
{.is-info}


### Notiz

Wird in der Bestellansicht ... angezeigt (Screenshot)

### Kategorie

Hier kannst du eine der angelegten Artikel-Kategorien (siehe eigener Abschnitt unten) auswählen. Falls keine geeignete Kategore verfügbar ist, wähle irgendeine aus, speichere den Artikel, erstelle die Kategorie, bearbeite den Artikel und wähle die neu erstellte Kategorie aus.

### Nettopreis und Mehrwertsteuer

Grundsätzlich gibt es zwei Möglichkeiten, Preise einzugeben:
1. als Bruttopreis: Nettopreis = Preis inkl. Mehrwertsteuer in Kombination mit 0 % Mehrwertsteuer 
2. als Nettopreis: Nettopreis = Preis exkl. Mehrwertsteuer in Kombination mit Mehrwertsteuersatz > 0 

Welche der beiden Varianten du auswählst, bleibt dir überlassen. Am einfachsten ist es, wenn du dich an der Preisliste der Lieferantin orientierst: 
- sind dort Nettopreise angegeben, übernimmst du diese und gibst den Mehrwersteuer Prozentsatz ein; die Foodsoft berechnet automatisch den Bruttopreis und zeigt das Ergebnis auch gleich unter "Endpreis" an. 
- sind dort Bruttopreise angegeben, übernimmst du diese und gibst für  Mehrwersteuer 0 ein. Der "Endpreis" ist gleich der Nettopreis. 

> Siehe auch grundlegende Infos zur [Mehrwertsteuer](/de/documentation/admin/finances/value-added-tax).
{.is-info}

> Der Standardwert für den Mehrwertsteuersatz, der beim Anlegen von neuen Artikeln im Feld erscheint, kann in den Einstellungen verändert werden.
{.is-info}

### Pfand

[Pfand](/de/documentation/admin/finances/deposits) wird im Bestellpreis inkludiert, und ist für Bestellerinnen nicht separat einsehbar. Daher ist es empfehlenswert, es bei der Artikelbezeichnung dazuzuschreiben, z.B.: **Joghurt im Glas (inkl. 50 ct Pfand)**. 

> Mehr dazu, wie Pfand ein einer Foodcoop gehandhabt werde kann unter [Pfand](/de/documentation/admin/finances/deposits).
{.is-info}


> Bei den Bestelllisten, die von der Foodsoft erstellt werden, um sie an die ProduzentInnen zu senden, ist das Pfand in den angegebenen Preisen nicht inkludiert. Manche ProduzentInnen stellen keine eigenen Rechnungen, sondern verwenden diese Bestelllisten als Rechnung. Wenn die ProduzentInnen das Pfand des zurückgegegeben Leerguts gut schrieben, muss das Pfand in den Bestelllisten inkludiert werden, indem das Pfand im Nettopreis der Artikel einberechnet und das Pfand auf 0 gesetzt wird. 
{.is-warning}


### Endpreis

Der Endpreis wird beim Bestellen in der Foodsoft angezeigt und beim
Abrechnen der Bestellungen den Foodsoft-Konten abgebucht.

**Endpreis = (Nettowert + Pfand) \* (100% + Mwst)** 

> Wenn ein Nettopreis und eine Mwst \> 0 eingegeben wird, muss also auch das Pfand als Nettopreis eingegeben werden, weil es auch mit der Mwst beaufschlagt wird. Falls nur der Bruttopfandwert bekannt ist, kann der Nettowert berechnet werden über 
> 
> Nettopfand = Bruttopfand / (100% + Mwst)
> {.is-warning}



### Herkunft

Herkunft des Artikels, je regionaler die Angabe, desto mehr Information über die Regionalität des Artikels. 

### Produzent

Falls Lieferantin Produkte unterschiedlicher Produzentinnen anbietet, sonst leer lassen.

### Bestellnummer

Kann von Lieferantin übernommen, selbst gewählt oder auch leer gelassen werden.

> Tipp: wenn Bestellnummern selbst gewählt werden, ist es gut, mit der Nummerierung nicht bei 1, sondern z.B. bei 1000 anzufangen, um  in den Bestelllisten, die an die Lieferantin gehen, Verwechslungen mit der Stückzahl zu reduzieren. Siehe "Artikel importieren".
{.is-info}


## Artikel anlegen

1. Lieferantin auswählen unter "Artikel > Lieferanten/Artikel"
1. auf Name der Lieferantin und dann auf Artikel oder 
1. in der entsprechenden Zeile direkt auf "Artikel" 
1. "Neuer Artikel" anklicken
1. Weitere Infos siehe "Artikel bearbeiten"

![neuer-artikel-1.png](/uploads-de/admin_suppliers_neuer-artikel-1.png)

Mit dem Scrollbalken rechts nach unten scrollen, um die unteren Eingabefelder sichtbar zu machen:
![neuer-artikel-2.png](/uploads-de/admin_suppliers_neuer-artikel-2.png)

> Wenn du ins Dunkle außerhalb des Eingabefeldes klickst, bewirkt es das gleiche wie wenn du auf "Schließen" drückst, und alle Änderungen sind verloren.
{.is-warning}

> Falls dein Display bzw. dein Browserfenster nicht recht hoch ist, kann es sein dass du die Schaltflächen "Schließen" und "Artikel erstellen" nicht sehen kannst. Abhilfe: das Browser Fenster so groß wie möglich machen (Doppelklick auf Titelleiste), falls das nicht reicht, Browser auf Vollbildansicht stellen mit F11. 
{.is-info}



## Artikel bearbeiten

1. Lieferantin auswählen unter "Artikel > Lieferanten/Artikel"
1. auf Name der Lieferantin und dann auf Artikel oder 
1. in der entsprechenden Zeile direkt auf "Artikel" 
1. In der Zeile des Artikels "Bearbeiten" anklicken

![prod-artikel-bearbeiten.png](/uploads-de/admin_suppliers_prod-artikel-bearbeiten.png)


## Artikel aktualisieren

Artikeldetails wie Preis, Bezeichnung, Menge können sich im Lauf der Zeit ändern. Hier wird beschrieben, wie diese Anpassungen durchgeführt werden können, und wie sich diese Änderungen auf bereits abgeschlossene oder laufende, noch offene Bestellungen auswirken.

- **Manuelle Aktualisierung durch Bearbeiten** einzelner oder aller Artikel: außer beim Preis wirken sich alle Änderungen auf alle Bestellungen aus, also auch auf aktuelle offene sowie bereits geschlossene oder abgerechnete Bestellungen (siehe [*https://github.com/foodcoops/foodsoft/issues/850*](https://github.com/foodcoops/foodsoft/issues/850)). Die Änderung eines Preises wirkt sich nur auf offene Bestellungen aus. Sobald eine Bestellung beendet wird, wird für jeden Artikel der Preis extra gespeichert, den der Artikel zu diesem Zeitpunkt hat. 

- **Bestehenden Artikel aus laufender Bestellung herausnehmen (nicht mehr verfügbar)**: *entweder*
     1. zuerst unter *Bestellungen > Bestellverwaltung > Bestellung ... bearbeiten* die laufende Bestellung bearbeiten, beim Artikel dort das Häkchen weg klicken und dann *Bestellung aktualisieren*. Falls der Artikel bereits bestellt wurde, erscheint ein Warnhinweis, *Warnung ignorieren* anwählen und erneut auf *Bestellung aktualisieren*; die Bestellungen der Bestellgruppen für diesen Artikel werden damit gelöscht! Dann erst unter *Artikel > Lieferanten/Artikel > Lieferantin > Artikel* den Artikel bearbeiten und als nicht nicht verfügbar markieren. Bei umgekehrter Reihenfolge der Schritte scheint der Artikel beim Bearbeiten der laufenden Bestellung nicht mehr auf und kann dadurch nicht entfernt werden, obwohl er in der Bestellansicht noch vorhanden ist. *Oder:*
     2. zuerst unter *Bestellungen > Bestellverwaltung > Bestellung ... Ansehen* die laufende Bestellung anschauen, ob und von wem der Artikel bereits bestellt wurde, falls die betroffenen Bestellgruppen informiert werden sollen. Dann unter *Artikel > Lieferanten/Artikel > Lieferantin > Artikel* den Artikel bearbeiten und als nicht nicht verfügbar markieren. Unter *Bestellungen > Bestellverwaltung > Bestellung ... bearbeiten* die laufende Bestellung bearbeiten und dann *Bestellung aktualisieren*. Falls der Artikel bereits bestellt wurde, erscheint ein Warnhinweis, *Warnung ignorieren* anwählen und erneut auf *Bestellung aktualisieren*; die Bestellungen der Bestellgruppen für diesen Artikel werden damit gelöscht!

- **Neuen Artikel in laufende Bestellung aufnehmen:** Unter *Artikel > Lieferanten/Artikel > Lieferantin > Artikel* den Artikel neu anlegen, dann unter *Bestellungen > Bestellverwaltung > Bestellung ... bearbeiten* die laufende Bestellung bearbeiten, beim neu hinzugefügten Artikel das Häkchen anklicken und schließlich *Bestellung aktualisieren*.


- Wenn es nötig ist, einen Artikel für eine laufende oder bevorstehende Bestellung zu aktualisieren, aber die Artikel von abgeschlossenen oder anderen laufenden Bestellungen nicht beeinflusst werden sollen, kann eine **Kopie des Artikels** angelegt werden. Original und Kopie müssen unterschiedliche Bezeichnungen haben. Deshalb z.B. 
     - vor dem Anlegen der Kopie die Bezeichung ändern von z.B. `Äpfel` auf `Äpfel bis JJJJ-MM-DD` (`JJJJ-MM-DD` ist das aktuelle Datum) und in der frisch angelegten Kopie das `bis JJJJ-MM-DD` wieder herauslöschen. Vorteil: der aktuelle Artikel heißt gleich wie gewohnt; Nachteil: für Bestellerinnen ist anhand der Artikelbezeichnung nicht auf den ersten Blick erkennbar, dass sich etwas geändert hat. Oder:
     - nach dem Anlegen der Kopie die Bezeichung der Kopie ändern von z.B. `Äpfel` auf `Äpfel ab JJJJ-MM-DD neuer Preis`, wobei `JJJJ-MM-DD`  das aktuelle Datum ist. Vorteil: für Bestellerinnen ist ersichtlich, dass sich etwas geändert hat, und was; Nachteil: diese Info ist nach einiger Zeit überflüssig.

- Alternativ können Artikel auch durch **Hochladen einer aktualisierten Import-Liste** aktualisiert werden. Dazu ist es erforderlich, jedem Artikel eine Bestellnummer (order nummer) zuzuweisen. Das können einfach fortlaufende Zahlen sein (1, 2, 3, …), falls die Lieferantin keine Artikelnummern vergibt. Ohne Bestellnummern kann die Foodsoft die Artikel der hochgeladenen nicht den bestehenden zuordnen. Die Artikeldaten von bereits abgeschlosssenen Bestellungen wie Name, Einheit usw. werden dabei auch verändert, mit Ausnahme der Artikelpreise, was z.B. im Fall der Änderung der Einheit zu einer verfälschten Darstellung alter Bestellungen führt, siehe oben erwähnter Github Issue. 

- Eine weitere Möglichkeit, insbesondere wenn keine Bestellnummern vergeben wurden, ist es, **Artikel zu löschen, und dann die Artikel neu hochzuladen**. Das geht jedoch nur, solange keine Bestellung offen ist. Die Daten von bereits abgeschlossenen oder abgerechneten Bestellungen (Artikelname, Einheit, Preis, …) werden dabei nicht verändert. Das mag in bestimmten Fällen auch so erwünscht sein.

## Artikel importieren

*Artikel \> Lieferanten \> Artikel \> Artikel hochladen*

Vorhandene Preisliste im Excel-Format (oder ähnlich) importieren:

1. Preisliste in Tabellenprogramm (Excel, LibreOffice oder OpenOffice) öffnen
2. Erste Zeile markieren (am linken Rand auf Zeilennummer 1 klicken) und mit Strg-Plus eine Zeile einfügen 
3. Foodsoft Artikel \> Lieferanten \> Artikel \> Artikel hochladen: Mustertabelle Kopfzeile kopieren und in die leere erste Zeile der Tabelle einfügen mit Strg+Alt+V (Excel) bzw. Strg+Gross(Shift)+V unformatierten Text einfügen
4. Spalten der original-Preisliste so umordnen, dass sie zur Kopfzeileder Mustertabelle aus der Foodsoft passen. Dazu Spalteninhalt ab der zweiten Zeile markieren und mit Strg+Alt an die richtige Position ziehen.
5. Artikelkategorien: Angelegte Kategorien siehe Foodsoft \> Artikel \> Kategorien. Bezeichnungen der Kategorien dürfen keine Leerstellen am Ende haben (passiert wenn aus Foodsoft in Tabelle kopiert). Die Kategorien werden mit den Kategorienamen und ggf. den Schlagwörtern abgeglichen, [mehr Infos dazu hier](/de/documentation/admin/suppliers#beschreibung).
6. Optional fortlaufende Bestellnummern vergeben, falls vom Lieferant keine Artikelnummern vorgesehen sind. Bestellnummern sind notwendig, wenn die Liste später aktualisiert und erneut hochgeladen wird, damit die aktualisierten den bestehenden Artikeln zugeordnet werden können. Bei den Bestelllisten, die die Foodsoft für die Lieferantin erstellt, wird die Bestellnummer in der ersten Spalte angezeigt. Um die Gefahr einer Verwechslung mit der Stückzahl in der zweiten Spalte zu reduzieren, können die Bestellnummern z.B. 1001, 1002, … sein.
7. Tabelle speichern und in Foodsoft importieren

> Beim Importieren einer .ods Datei aus LibreOffice wird die Kategorie nicht importiert, wenn die Datei aber im .xls Format gespeichert wird, klappt es (Mirko 2022-01).
{.is-danger}


## Artikel exportieren

Alle Artikel der Produzentin werden in eine [Textdatei im CSV Format](/de/documentation/admin/lists) gespeichert, können bei Bedarf mit einem Tabellenprogramm wie Excel oder Calc (LibreOffice) bearbeitet und mit der Import Funktion auch wieder bei einer anderen Produzentin oder in der Foodsoft einer anderen Foodcoop importiert werden.

Wird die CSV Datei in einer deutschen Office Version bearbeitet, kann es sein, dass Dezimaltrenner Punkt durch Komma ersetzt wird, was beim Einlesen der CSV Datei nicht akzeptiert wird. Abhilfe: im ODS-Format speichern.


## Artikel löschen

> Saisonal bzw. vorübergehend nicht verfügbare Artikel sollten besser als nicht verfügbar gekennzeichnet statt gelöscht werden. Sie können dann jederzeit wieder verfügbar gemacht werden.
{.is-info}


> Artikel können nicht gelöscht werden, solange sie Teil einer offenen Bestellung sind.
{.is-warning}


Bei abgeschlossenen oder abgerechneten Bestellungen bleiben die angezeigten Artikeldaten wie Name, Einheit, Preis erhalten, auch wenn der entsprechende Artikel gelöscht wird. Die anderen Details gehen allerdings verloren.

### Alle Artikel einer Lieferantin löschen
Aie Anzahl der angezeigten Artikel erhöhen, sodass alle angezeigt werden, am Ende der Liste „alle auswählen“, rechts daneben "Artikel löschen". 
> Es werden nur jene Artikel ausgewählt und gelöscht, die in der aktuellen Ansicht sichtbar sind.
{.is-warning}




# Kategorien

Kategorien ermöglichen es, Artikel zu gruppieren. In der Bestellansicht wird für jede Kategorie eine Überschrift angelegt und dann die Artikel dieser Kategorie. Kategorien sind global, das heißt jede Kategorie  ist für alle Lieferantinnen gleichermaßen gültig und auswählbar. 

In einer neu angelegten Foodsoft-Instanz gibt es zunächst nur die Kategorie "other". Sie kann z.B. in "sonstiges" umbenannt werden. Andere Kategorien müsst ihr für eure Foodcoop selbst erstellen.

## Beispiele


### Beispiel Gemüselieferantin

Kategorien
- Gemüse
- Säfte
- Öle
- Essig
- Eingemachtes
- Pflanzen
- Obst

Die Bestellliste sieht dann beispielsweise so aus (dargestellte Kategorien Eingemachtes, Essig und Gemüse):

![bestellung-kategorien.png](/uploads-de/admin_suppliers_bestellung-kategorien.png)

### Beispiel Weinlieferantin
- Rotwein
- Weißwein
- Sekt und Prosecco

Da aus den Namen der Weine oft nicht hervorgeht, ob es sich um einen Weiß- oder Rotwein handelt, ist es über die Kategorie klar zugeordnet: 

- **Rotwein**
   - Zweigelt
   - St. Laurent
- **Weißwein**
   - Gemischter Satz
   - Muskateller
- **Sekt und Prosecco**
   - Riesling
   - Zweigelt rosé

## Kategorien anzeigen

Artikel > Kategorien

## Neue Kategorie anlegen

Artikel > Kategorien > Neue Kategorie anlegen

### Name
Eine möglichst selbsterklärende und prägnante Bezeichnung für die Kategorie.

> Beim Bestellen werden die Artikel nach Kategorien gruppiert und darin alphabetisch sortiert angezeigt.
> 
> Die Kategorien werden ebenfalls alphabetisch sortiert angezeigt.
{.is-info}

> Tipp: Damit die Kategorien beim Bestellen nach einer bestimmten Reihenfolge angezeigt werden, z.B. sodass Frischwaren zuoberst stehen, vor den Kategorienamen einen Prefix setzen.
> 
> Beispiel:
> 
> (a) Fruchtgemüse
> 
> (a) Wurzelgemüse
> 
> (c) Eier
> 
> (m) Getreideprodukte
> 
> usw.
{.is-info}

### Beschreibung

Dieses optionale Feld kann entweder zur Beschreibung der Kategorie (wird nur in der Kategorien-Liste angezeigt, nicht beim Bestellen) oder als kommagetrennte Liste an Schlagwörtern für den [Import per CSV/Excelliste](/de/documentation/admin/suppliers#artikel-importieren) verwendet werden, um neue Artikel automatisiert bestimmten Kategorien zuzuordnen.

> Die Inhalte der Spalte "Kategorie" in der CSV werden sowohl mit den Kategorienamen als auch mit den Schlagwörtern aus der Kategoriebeschreibung verglichen. Ist die Kategorie in der CSV in einem Kategorienamen enthalten oder stimmt exakt mit einem Schlagwort überein (Groß-/Kleinschreibung egal), wird die Kategorie mit der engsten Übereinstimmung vorausgewählt.
> 
> Die Kategorie des Artikels kann im darauffolgenden Menü noch manuell angepasst werden, bzw. muss ausgewählt werden, falls keine Übereinstimmung gefunden wurde.
{.is-info}

> Beispiel:
> 
> Kategorie "(a) Fruchtgemüse"
> 
> Beschreibung "Zucchini, Tomaten, Paradeiser, Paprika"
> 
> -> CSV mit Artikel mit Kategorie "Paprika" oder "Frucht" wird der Kategorie "(a) Fruchtgemüse" zugeordnet, Artikel mit Kategorie "Paprika grün" oder "Diverses Fruchtgemüse" jedoch nicht.
> 
> Beschreibung "Zucchini, Tomaten, Paradeiser, Paprika grün"
> 
> -> CSV mit Artikel mit Kategorie "Paprika grün" wird der Kategorie "(a) Fruchtgemüse" zugeordnet, Artikel mit Kategorie "Paprika" jedoch nicht.
{.is-info}

> Die Kategoriebeschreibung kann aus maximal 255 Zeichen bestehen.
{.is-warning}

## Kategorie bearbeiten

Hier kannst du Name und Beschreibung einer Kategorie anpassen. Die interne Zuordnung von Artikeln und Kategorien erfolgt über eine ID (eine eindeutige Zahl, die die Foodsoft automatisch für jede neue erstellte Kategorie vergibt), sodass Zuordnungen erhalten bleiben, auch wenn du den Namen der Kategorie änderst.

## Kategorie löschen

> Eine Kategorie kann nicht gelöscht werden, solange Artikel ihr zugeordnet sind. Es erscheint dann eine Fehlermeldung.
> 
> Die betreffenden Artikel müssen erst herausgesucht und entweder gelöscht oder anderen Kategorien zugewiesen werden, danach lässt sich die Kategorie löschen.
{.is-warning}

