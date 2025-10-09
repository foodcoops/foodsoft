---
title: Bestellungen
description: Verwaltung von Bestellungen und Rechnungen
published: true
date: 2025-05-05T20:57:33.733Z
tags: 
editor: markdown
dateCreated: 2021-04-20T22:03:00.312Z
---

# Einleitung

## Lebenszyklus von Bestellungen

Eine Bestellung ist immer genau einer [Lieferantin](/de/documentation/admin/suppliers) zugeordnet. Es können gleichzeitig beliebig viele Bestellungen aktiv sein, von verschiedenen aber auch von der selben Lieferantin. Letzteres macht beispielsweise Sinn, wenn bei einer Lieferantin Artikel mit unterschiedlichen Lieferzeitpunkten bestellt werden: hier kann für jedes Abholdatum eine eigene Bestellung mit den jeweilgen Artikeln angelegt werden, die aber gleichzeitig als offene Bestellung laufen und damit gleichzeitig bestellt werden können. 

Bestellungen durchlaufen in der Regel folgende Stadien, wobei eine Änderung meist nur vorwärts möglich ist:

1. Bestellung ist noch nicht offen, weil sie erst in der Zukunft startet (optional); sie ist in diese Stadium nur für Administratorinnen sichtbar.
2. Bestellung ist **offen (laufende Bestellung)**: Bestellgruppen ([Definition Bestellgruppe](/de/documentation/usage/profile-ordergroup), [Administration](/de/documentation/admin/users)) können ihre Bestellungen erstellen und bearbeiten. 
3. Bestellung ist **beendet**: Bestellgruppen können ihre Bestellungen nicht mehr bearbeiten, Bestellungen werden an Lieferantinnen geschickt; Bestellung kann nicht mehr wieder geöffnet werden, um von Bestellgruppen bearbeitet zu werden. Nach der Lieferung kann die Bestellung grundsätzlich nur noch mit spezieller Berechtigung  angepasst werden (z.B. wenn nicht alles geliefert wurde, was bestellt wurde)
3. Bestellung **in Empfang genommen**: Die bestellten Mengen wurden an die tatsächlich gelieferten Mengen angepasst. Dieser Vorgang kann öfters erfolgen, solange die Bestellung noch nicht abgerechnet wurde.
4. Bestellung ist **abgrechnet**: Bestellung kann nicht mehr verändert werden, die Beträge wurden den Bestellgruppen von ihren Foodsoft-Konten endgültig abgebucht.

Die folgende Skizze stellt diesen Lebenszyklus dar. Der blaue Pfeil in der Mitte deutet die Zeitachse an: 
![bestellung.png](/uploads-de/admin_orders_bestellung.png =400x)

Die folgende Tabelle zeigt, was in welchem Stadium der Bestellung geschieht bzw. möglich ist.

Bestellstatus: | laufend (offen)  | beendet | abgerechnet
--------------|----------|---------|------------
Mitglieder können ihre Bestellung bearbeiten | ja | -- | -- |
Admins können Zeitpunkt Bestellende anpassen  | ja | -- | -- |
Admins können Abholdatum anpassen | ja | (ja) | -- |
Admins können Bestellungen der Mitglieder anpassen | --  | ja | --
Mitglieder verfügbares Guthaben verringert | ja | ja | --
Mitglieder Kontostand verringert | -- | -- | ja

## Bestellungen abrechnen und Rechnungen anlegen

Beim Bestellen werden die Beträge den Bestellgruppen noch nicht von ihren Konten abgebucht, es verringern sich zunächst nur die verfügbaren Guthaben. Erst beim Abrechnen einer Bestellung werden die Beträge für diese Bestellung den Bestellgruppen von ihren Foodsoft-Konten abgebucht.
Nur vorher können noch Anpassungen durchgeführt werden, wenn es z.B. bei der Lieferung Abweichungen zur Bestellung gibt. Weiters sollte die Rechnung des Produzenten angelegt und mit der Bestellung verknüpft werden, um vergleichen zu können, ob sich die Geldbeträge von Rechnung und Bestellung decken.

> Achtung auf die Einhaltung der Reihenfolge: sobald eine Bestellung abgerechnet ist, kann sie nicht mehr angepasst werden.
{.is-warning}

Daher sollte folgende Reihenfolge strikt eingehalten werden:

1. Bestellung an tatsächlich gelieferte Artikel anpassen
2. Rechnung in der Foodsoft für die Bestellung anlegen (Details siehe unten). Wenn die ProduzentInnen Rechnungen über mehrere Bestellungen gesammelt ausstellen, warten, bis die Rechnung kommt und für die betroffenen Bestellungen eine gemeinsame Rechnung in der Foodsoft anlegen. 
3. Rechnungsdaten der Rechnung von der ProduzentIn in die Foodsoft eingeben und prüfen: stimmen Beträge von Bestellung/Lieferung (“Total”) und der pfandbereinigten Rechnung überein? 
4. Rechnung bezahlen per Überweisung vom Foodcoop Bankkonto 
5. Bankdaten importieren und zuordnen: Rechnung wird in der Foodsoft als bezahlt gekennzeichnet 
6. Bestellung abrechnen 

## Erforderliche Berechtigungen für Bestellverwaltung

- Bestellungen anlegen, bearbeiten, beenden, anpassen, Lieferungen entgegenehmen, Rechnungen anlegen: **Bestellungen**. Benutzerinnen, die nur diese Berechtigung haben, können nur die von ihnen angelegten Bestellungen und Rechnungen bearbeiten.
- Lagerbestellungen anlegen: **Lieferanten** oder **Artikeldatenbank**
- Bestellungen abrechnen: **Finanzen**

Berechtigungen vergeben siehe [Benutzerverwaltung](/de/documentation/admin/users).

# Bestellungen anlegen

Es gibt folgende zwei Arten von Bestellungen, die an unterschiedlichen Stellen erstellt werden:

- Bestellung der Foodcoop-Mitglieder (Bestellgruppen) bei Lieferantin: "Bestellung"
   - optional: Foodcoop bestellt (zusätzlich zu den Bestellgruppen) bei Lieferantin Artikel fürs Lager: "Lagerbestellung"
- Bestellung der Foodcoop-Mitglieder (Bestellgruppen) im Lager: "Lagerbestellung"



![lagerbestellung3.png](/uploads-de/admin_orders_lagerbestellung3.png =400x)

## Bestellung bei Lieferant

Bestellung bei Lieferantin anlegen: **Bestellungen > Bestellverwaltung > neue Bestellung anlegen** > Lieferant auswählen (Berechtigung Bestellen erforderlich)

![bestellung-anlegen1.png](/uploads-de/admin_orders_bestellung-anlegen1.png)


> *Bestellung kopieren* erspart bei regelmäßigen Bestellungen Aufwand. Allerdings werden dabei zunächst nur die Artikel der kopierten Bestellung übernommen. 
{.is-info}


> Die Foodsoft erlaubt derzeit noch keine automatisierte Erstellung von Bestellungen. Auch wenn sich z.B. eine Bestellung wöchentlich exakt wiederholt, muss sie dennoch jede Woche neu angelegt werden.
{.is-info}


## Bestellung aus Lager

Bestellung für Foodcoop-Mitglieder aus dem Foodcoop [Lager](/de/documentation/admin/storage) anlegen: 
**Artikel > Lager > Lagerbestellung online stellen** (Berechtigung Lieferanten oder Artikeldatenbank erforderlich)

![lagerbestellung.png](/uploads-de/admin_orders_lagerbestellung.png)



## Details für Bestellung

![admin-bestellung-neu-details.png](/uploads-de/admin_orders_neu-details.png)

### Bestellzeitraum: "Läuft vom", "Endet am"

Eine Bestellung ist im festgelegten Zeitraum „offen“, d.h. dass Bestellgruppen bestellen können bzw. ihre Bestellung verändern können. 
- Beginndatum und Zeit ("Läuft vom"): aktuelles Datum und Uhrzeit, bearbeitbar
- Enddatum und Zeit ("Endet am"): leer oder der Datum und Uhrzeit des nächsten Wochentags, der über Administration > Einstellungen > Finanzen als  Standard-Bestellschluss festgelegt wurde.

Sobald eine Bestellung beendet ist, 

- können die Bestellguppen ihre Bestellung nicht mehr verändern. Üblicherweise ist das erforderlich, weil dann die Bestellungen an die Lieferanten geschickt werden, und Änderungen daher nicht mehr berücksichtigt werden könnten.  
- kann das Abholdatum nicht mehr verändert werden

### Abholung

Das Abholdatum ist wichtig, wenn Abhhollisten über die Funktion *Bestellen \> Abholtage* erstellt werden, damit alle Bestellungen eines Abholtages gemeinsam auf den Listen erscheinen. Es kann nach dem Beenden der Bestellung nicht mehr geändert bzw. gesetzt sein. Daher die
Empfehlung, Bestellungen erst mit einem Enddatum zu versehen bzw. zu beenden, wenn auch das Abholdatum feststeht.

### Endeaktion: Optionen für Aktionen beim Bestellende

![bestellung-anlegen.png](/uploads-de/admin_orders_bestellung-anlegen-endaktion.png)

- **keine automatische Aktion:** die Bestellung bleibt offen. Sinnvoll, wenn eine Mindestbestellmenge erreicht werden soll, und die Bestellung so lange hinausgezögert werden soll, bis sie erreicht wird. Oder wenn unklar ist, wann die Lieferung genau erfolgen wird (Abholdatum unbekannt).
- **Bestellung beenden**: die Bestellung wird automatisch beendet, und kann dann auch nicht mehr geöffnet werden.
- **Bestellung beenden und an Lieferantin schicken:** die Bestellliste wird von der Foodsoft automatisch als PDF Anhang per Email an die Lieferantin und an das Foodsoft Mitglied geschickt. 
- **Bestellung beenden und an Lieferantin schicken sofern die Mindestbestellmenge erreicht wurde**: bei jeder Lieferantin kann eine Mindestbestellmenge als Geldbetrag angegeben werden. Dieser Mindestbetrag und wieviel davon schon erreicht wurde, wird den Bestellgruppen beim Bestellen angezeigt. Wenn die Bestellung nicht zustande kommt, sollte
  - Eine Nachricht an die Bestellgruppen geschickt werden (Funktion „An die Mitglieder schicken, die bei einer Bestellung etwas bestellt haben“, siehe [Kommunikation](/de/documentation/usage/communication)). Diese Funktion kann auch direkt über das Brief Symbol beim Bearbeiten der Bestellung ausgelöst werden.
  - Bestellen \> Bestellverwaltung \> Beendet \> Bestellung (Zeile mit der betroffenen Bestellung suchen)... \> in Empfang nehmen, Alle auf Null setzen, Bestellung in Empfang nehmen. Damit wird dann auch nichts abgerechnet, und die auf den Bestelllisten (Bestellen \> Abholtage) scheint bestellt: x, erhalten: 0 auf, in grau statt schwarz. Das sollte idealerweise möglichst rasch nachdem die Bestellung gescheitert ist, passieren, damit es bei den ausgedruckten Bestelllisten (siehe unten) berücksichtigt ist. 
  - Vorschlag für Automatisierung: [*https://github.com/foodcoops/foodsoft/issues/858*](https://github.com/foodcoops/foodsoft/issues/858)
       
### Notiz

Kommentar zur Bestellung, wird den Mitgliedern im Bestellfenster angezeigt.

![admin-bestellung-neu-details-notiz.png](/uploads-de/admin_orders_neu-details-notiz.png)



### Artikel für Bestellung auswählen

Es werden nur die Artikel des Lieferanten zur Bestellung hinzugefügt, die aktuell verfügbar sind (Lager: Lagerstand \> 0). 

> Wenn Artikel nachträglich verfügbar werden, hinzugefügt oder ins Lager geliefert werden, muss die Bestellung bearbeitet werden und die zusätzlichen Artikel ausgewählt werden (oder: „alle auswählen“ am unteren Ende der Liste).
{.is-warning}

### Bestellung erstellen

Mit "Bestellung erstellen" wird die Bestellung gespeichert und kann, solange sie noch nicht beendet ist, noch bearbeitet werden.






# Bestellungen bearbeiten

Bestellungen können, solange sie noch nicht beendet sind,  wahlweise über folgende Wege bearbeitet werden:
- *Bestellungen > Bestellverwaltung > Bestellung > Bearbeiten* (Bestellungen Lieferantin und Lager) 
- *Bestellungen > Bestellverwaltung > Bestellung > Anzeigen > Bearbeiten* (Bestellungen Lieferantin und Lager) 
- *Artikel > Lieferantin > Letzte Bestellungen > Bestelldatum > Bearbeiten* (nur die letzten 10 Bestellungen der Liferantin)



Es können Beginn und Ende der Bestellung, Endaktion, Notiz und die verfügbaren Artikel bearbeitet werden. 
Änderungen werden erst übernommen, wenn das Bearbeiten mit *Bestellung aktualisieren* abgeschlosen wird. Wenn Artikel entfernt werden, die schon bestellt wurden, wird eine Warnung ausgegeben, die bestätitgt werden muss. Artikel, die nach dem Erstellen der Bestellung neu hinzugekommen oder verfügbar gemacht wurden, müssen in der Bestellung aktiviert werden, das erfolgt nicht automatisch. 

Wenn Bestellungen beendet sind, können sie nur mehr an die Lieferung angepasst werden ("in Empfang nehmnen") und für eine neue Bestellung kopiert werden, jedoch nicht mehr bearbeitet werden (wie es doch geht, siehe  *Bestellung beenden*).






# Bestellungen anzeigen

## Überblick Bestellungen

### Alle Bestellungen
Beide Arten von Bestellungen (Lieferantin und Lager) können unter *Bestellungen > Bestellverwaltung > Anzeigen* angezeigt werden. Die Anzeige ergolgt in einer chronologischen Liste, sortiert nach dem Datum des Bestellendes, neueste Bestellungen zuerst, in folgende Teilabschnitte gegliedert:

- laufend (auch wenn das Beginndatum in der Zukunft liegt, und die Bestellung noch nicht allgemein sichtbar ist)
- beendet
- abgrechnet

Für die Anzeige der Details einer Bestellunge gibt es jeweils die Schaltfläche *Anzeigen*.

### Bestellungen einer Lieferantin
Die letzten 10 Bestellungen einer Lieferantin können unter *Artikel > Lieferantin > Letzte Bestellungen* angezeigt werden. Pro Bestellung gibt es folgende Links:
- **Datum** (läuft von) führt zur Detailansicht der Bestellung
- **Status** führt zur entsprechenden Seite *Finanzen > Bestellungen abrechnen* der jeweiligen Bestellung (Zugriffsberechtigung *Finanzen* erforderlich!), siehe *Bestellungen anpassen* und *Bestellungen abrechnen* 

## Detailansicht Bestellungen

### Standardansicht: Artikelübersicht
Komplette Artikelliste der Lieferantin wird angezeigt, nicht bestellte Artikel grau, bestellte Artikel grün mit der gesamten Anzahl bestellter Einheiten

### Sortiert nach Gruppen
Überschrift für jede Bestellgruppe, die etwas bestellt haben, darunter die bestellten Artikel der Bestellgruppe.

### Sortiert nach Artikeln
Überschrift für jeden Artikel (sofern mindestens 1 Einheit bestellt wurde), darunter die Bestellgruppen und die von ihnen jeweils bestellten Einheiten.

## Lagerbestellung bei Lieferantin

Zusätzlich zu den direkten Bestellungen der Mitglieder kann bei einer Bestellung bei der Lieferantin in der Detailansicht der Bestellung eine Lagerbestellung (Foodcoop bestellt bei Lieferant um Lagerbestand aufzufüllen) hinzugefügt werden, solange die Bestellung noch offen ist. Diese Artikel scheinen dann in der Bestellliste, die an den Lieferanten geht, auch auf, nicht aber in der Abrechnung und bei “Bestellung annehmen”(?). Wenn die Artikel geliefert sind, ist fürs Lager nochmal extra eine Lieferung für diese Artikel anzulegen, damit sie in den Lagerbestand aufgenommen werden. Für die Rechnung sind dann sowohl Bestellung und (Lager-)Lieferung anzugeben.

![lagerbestellung2.png](/uploads-de/admin_orders_lagerbestellung2.png)


# Bestellung beenden

Eine Bestellung 
- endet automatisch, wenn dies vorher so eingestellt wurde (siehe oben), 
- muss manuell beendet werden, wenn keine automatisches Beenden eingestellt wurde (siehe oben),
- kann unabhängig davon jederzeit manuell (sowohl nach Bestellendedatum, falls noch offen, als auch vorzeitig) über "Beenden" beendet werden.

> Die Optionen für *Aktionen beim Bestellende* (siehe oben) wie z.B. die Bestellung per Email an die Lieferantin schicken,  werden nur ausgeführt, wenn die Bestellung automatisch endet. Bei einer vorzeitigen manuellen Beendigung werden sie nicht ausgeführt.
{.is-info}

> "Beenden" kann nicht mehr rückgängig gemacht werden. Die Bestellung ist dann gesperrt und kann nicht mehr verändert werden (keine Veränderung der Bestellung durch Bestellgruppen möglich). Eine Wiederaufnahme der Bestellphase ist nicht mehr möglich. 
{.is-warning}

## Beendete Bestellung bearbeiten: Abholdatum nachträglich anpassen
Eine beendete Bestellung kann mit folgendem Trick bearbeitet werden: 
1. entsprechende Bestellung anzeigen
2. in der Browseradresszeile `/edit` hinzufügen

also z.B.:
- Browser-URL zum Anzeigen: `https://app.foodcoops.at/franckkistl/orders/4014`
- Browser-URL zum Bearbeiten: `https://app.foodcoops.at/franckkistl/orders/4014/edit`

Das macht aber eigentlich nur Sinn, um das **Abholdatum anzupassen** oder nachzutragen.

> Das Datum bei *Endet am* einer bereits beendeten Bestellung auf ein Datum in der Zukunft zu setzten, ändert nichts am Status der Bestellung, sie bleibt trotzdem beendet und es kann nichts mehr bestellt werden. 
{.is-warning}


# Bestelllisten für Lieferantinnen

- **Automatisch** (siehe oben beim Anlegen einer Bestellung: Endeaktion ...  an Lieferantin schicken) über die Foodsoft: Foodsoft versendet Email an Lieferantin mit automatisch erstellter Bestellliste als PDF und CSV Datei im Anhang, CC an FC Mitglied, das die Bestellung erstellt hat.
- **Manuell**:
    - Über die Funktion Bestellverwaltung > Bestellung anzeigen > **an Lieferantin schicken**: ...
    -  Bestelllisten herunterladen (Bestellungen > Bestellverwaltung > Bestellung anzeigen > **Download > Fax PDF/Text/CSV**) und z.B. per Email versenden



> Die Funktion "Download" ist nur für beendete Bestellungen verügbar.
{.is-warning}

> Die Fax-Downloads enthalten nur jene Artikel, von denen etwas bestellt wurde, und hier auch nur die Gesamtzahl der Artikeleinheiten, ohne die Information, welche Bestellgruppe wieviel davon bestellt hat. 
{.is-info}

## Per E-Mail an Lieferantin schicken

> Die Email wird von der Foodsoft an die Lieferantin und an die Email-Adresse der Benutzerin (CC und Reply-to) und im Namen der Benutzerin geschickt, die gerade angemeldet ist. Es wurde aber auch beobachtet, dass Email und Name der Benutzerin verwendet wurden, die die Bestellung erstellt hat (Mirko 2025-05 - noch öfter testen!).  
{.is-warning}

> Laut Quellcode der Foodsoft in **app/controllers/orders_controller.rb** sollte die gerade angemeldeten Benutzerin verwendet werden:   
    def send_result_to_supplier
        order = Order.find(params[:id])
        order.send_to_supplier!(**@current_user**)  
{.is-danger}


Die Email enthält:

- Betreff: [*...Foodcoop...*] Neue Bestellung für *...Lieferantin...* (Abholung: 25.04.2025)
- Von: Foodsoft <noreply@app.foodcoops.at>
- An: *...E-Mail Lieferantin...*
- cc: *...E-Mail Benutzerin...*
- reply-to: *...E-Mail Benutzerin...*

Guten Tag,

die Foodcoop ... möchte gerne eine Bestellung abgeben.

Im Anhang befinden sich ein PDF und eine CSV-Tabelle.

Mit freundlichen Grüßen

*...Benutzerin Vor- und Nachname ...*
*...FoodCoop...*

--
Foodsoft: https://app.foodcoops.at/...
Foodcoop: http://www...

### Beispiel Email

![admin_orders_email-supplier.png](/uploads-de/admin_orders_email-supplier.png)



## Beispiel Fax PDF

![bestellung-download.png](/uploads-de/admin_orders_bestellung-download.png)

In diesem Beispiel wurden bei den Artikel der Lieferantin keine Bestellnummern eingegeben, sodass die erste Spalte leer ist. 
> Die Liefarantin druckt diese Liste aus und vermerkt in der ersten Spalte händisch die tatsächlich gelieferte Menge, falls es Abweichungen gibt. So wird die Bestellliste zum Lieferschein und kommt mit der Lieferung in die Foodcoop zurück.

![bestellliste-faxpdf.png](/uploads-de/admin_orders_bestellliste-faxpdf.png) 

> Die Artikel sind alphabetisch nach Artikelname und im Gegensatz zu den Bestelllisten bei Bestellen auch nicht nach Kategorien sortiert. Achtung z.B. bei ähnlichen Produkten in verschiedenen Kategorien, z.B. Salat (Kategorie Gemüse) und Salat (Kategorie Pflanze).  
{.is-warning}

> Weitere Beispiel Screenshots
{.is-danger}

> Die Download-Optionen "Gruppen/Artikel/Matrix PDF" enthalten Foodcoop-interne Informationen (welche Bestellgruppe hat von welchem Artikel wieviel bestellt), die normalerweise für die Lieferantin nicht relevant sind.
{.is-info}


# Bestelllisten für die Foodcoop

Die Foodcoop benötigt Bestelllisten für die Aufteilung der eingegangenn Lieferungen auf die Bestellgruppen.
- Für einzelne Bestellungen über Bestellungen > Bestellverwaltung > Bestellung anzeigen > Download > Gruppen/Artikel/Matrix PDF" 
- Für die gesamten Bestellungen eines Abholtags besser über Bestellungen > [Abholtage](/de/documentation/usage/order)

> Die Funktion "Abholtage" muss für dich freigegeben sein - bitte eine Administratorin deiner Foodsoft darum
{.is-warning}

> Die folgenden Beispiele sind für eine Bestellung, wo nur die Bestellgruppe *LLTest* etwas bestellt hat. Sie geben daher teilweise ein unvollständiges Bild der Darstellungsart wieder und sollten duch ein Beispiel mit mindestens 2 Bestellgruppen ersetzt werden.
{.is-danger}


## Gruppen PDF

In einem  Gruppen PDF sind die bestellten Artikel nach Bestellgruppen zusammengefasst. Diese Liste ist für die Mitglieder zum Abholen ideal. 

![admin-bestellungen-gruppenpdf.png](/uploads-de/admin_orders_gruppenpdf.png)

## Artikel PDF
Ein Artikel PDF sind die bestellten Artikel nach Artikel zusammengefasst. Diese Liste ist fürs Aufteilen der Artikel  auf die Mitglieder ideal. 

![admin-bestellungen-artikelpdf.png](/uploads-de/admin_orders_artikelpdf.png)

## Matrix PDF

Die Matrix Darstellung kombiniert die Gruppen- und Artikeldarstellung in einer einzelnen Matrix (Tabelle), eine Zeile für jeden Artikel und eine Spalte für jede Bestellgruppe, in den Matrixfeldern die jeweils bestellte Anzahl.
Zusätzlich zur Matrix gibt es noch eine Liste *Artikelübersicht*.

![admin_orders_matrixpdf-2.png](/uploads-de/admin_orders_matrixpdf-2.png){.align-center}

## Fax PDF
Das Fax PDF ist eine Liste der insgesamt bestellten Artikelmengen, ohne Aufschlüsselung, was davon jeweils welche Bestellgruppen bestellt haben. Diese Liste kann verwendet werden, um sie der Lieferantin nochmals zukommen zu lassen (falls das Original verloren gegangen ist), oder um die eingegangene Lieferung zu kontrollieren. 
![admin-bestellungen-faxpdf.png](/uploads-de/admin_orders_faxpdf.png)


# Bestellungen an Lieferung anpassen

Nicht immer wird genau das geliefert, was bestellt wird. Manchmal sind Artikel nicht mehr oder nur beschränkt verfügbar, werden daher nicht geliefert oder durch andere ersetzt, oder die Lieferantin irrt sich - so können sowohl mehr als auch weniger Artikel als bestellt geliefert werden.
> Wenn ihr die Foodsoft nicht zum Abrechnen verwendet, könnt ihr diesen Schritt überspringen, und die Bestellung sofort abrechnen. Dieser Schritt ist wichtig, damit Bestellungen als abgeschlossen gelten und von der Foodsoft auch also solche (nicht mehr) dargestellt werden können. Auch wenn ihr euch zu einem späteren Zeitpunkt entscheidet, die Foodsoft doch für die Abrechnung zu verwenden, habt ihr dann einen sauberen Umstieg - sonst müsstet ihr nachträglich alle bisherigen Bestellungen abrechnen.
{.is-info}

Nur wenn ihr die Foodsoft auch zum Abrechnen verwendet, ist es wichtig, die Bestellungen an die tatsächliche Lieferung anzupassen, damit
- die Rechnung der Lieferantin mit der Bestellsumme in der Foodsoft zusammenstimmt, und
- den Mitgliedern  Beträge von ihrem Guthaben abgebucht werden, die dem entsprechen, was sie tatsächlich bekommen haben.

> Beim Beenden einer Bestellung wird für jeden Artikel jeweils die Summe der von den Bestellgruppen bestellten Artikelzahlen gebildet und als separater Wert in der Foodsoft gespeichert, damit sie z.B. an die Lieferantin übermittelt werden kann. Von diesem Zeitpunkt an wird diese gesamte Anzahl eines Artikel nicht mehr automatisch an die einzelnen Anzahlen der von den Bestellgruppen bestellten Artikelzahl angepasst und umgekehrt! 
{.is-warning}

Für die im folgenden beschriebenen Anpassungen ist es daher oft nötig, sowohl die gesamte Anzahl anzupassen (*in Empfang nehmen*), als auch die Anzahlen der Bestellgruppen anzupassen, und darauf zu achten, dass die gesamte Anzahl immer der Summe der einzelnen Bestellgruppen entspricht, weil
- die **gesamte Artikelzahl** für die Berechnung des Bestell-Geldwerts herangezogen wird, der z.B. bei der Rechnung aufscheint und mit der Rechnungssumme übereinstimmen sollte, und
- die **Artikelzahlen der einzelnen Bestellgruppen** beim Abrechnen für die Berechnung der Abbuchungsbeträge von den Foodsoft-Konten der Bestellgruppen herangezogen werden.

Eine Abweichung von Gesamtzahl und Summe aus den Einzelbestellungen wird durch ein rotes Rufzeichen angezeigt.


## Bestellungen in Empfang nehmen

Die Funktion *In Empfang nehmen* ist so, dass du bei Artikeln, wo eine Anzahl abweichend von der bestellten geliefert wurde, die tatsächlich gelieferte Anzahl in das leere Feld schreibst. 

- Es können auch **Dezimalzahlen** mit Punkt eingegeben werden (z.B: 3.5 für dreieinhalb Einheiten), wenn die gelieferte Menge von der bestellten abweicht.
- Wenn die Bestellmenge mit der Liefermenge übereinstimmt, können die entsprechenden **Felder frei gelassen** werden. Es empfiehlt sich aber dennoch, alle Felder auszufüllen, da dadurch einfach nachvollziehbar ist, ob alle Mengen kontrolliert wurden.
- Wenn die Bestellung komplett ausgefallen ist (z.B. weil die Mindestmenge nicht erreicht wurde), kannst du die Funktion *alle auf Null setzen* verwenden.

Dann klickst du auf *Bestellung in Empfang nehmen*.

> Man sieht die bestellten, aber nicht gelieferten Artikel dann nur mehr in der Gruppen-PDF Ansicht.
{.is-info}


## Lagerbestellung

Wenn bei einer Bestellung auch für das Lager etwas mit bestellt wurde (siehe oben: *Lagerbestellung bei Lieferantin*):
1. Eine [Lager Lieferung](/de/documentation/admin/storage) für die entsprechenden Artikel anlegen
1. Die ins Lager gelieferten Artikel aus der Bestellung herausnehmen: sowohl Gesamtzahl über *Bestellung in Empfang nehmen*, als auch die *Lagerbestellung* (siehe *Mitglieder-Bestellungen anpassen*). 
> Die Lagerlieferung würde in der Rechnungsbilanz sonst doppelt berücksichtigt, einmal im Bestellwert (obwohl die Lagerbestellung beim Abrechnen niemandem abgebucht wird), und einmal in der Lager-Lieferung. Das müsste nicht sein, wenn die Foodsooft den Wert der Lagerbestellung bei der Berechnung der Bestellsumme ausschließen würde. **Issue auf Github anlegen, oder besser: Foodsoft Pull Request erstellen!**
{.is-danger}


## Mitglieder-Bestellungen anpassen

> Für diese Funktion ist die Berechtigung *Finanzen* erforderlich!
{.is-warning}

Unter *Bestellverwaltung > Beendet > Anzeigen >  Sortiert nach Gruppen/Artikeln* oder unter *Finanzen > Bestellungen abrechnen* kannst du die Aufteilung der gelieferten Artikel auf die Bestellgruppen anpassen.
In der Bestellverwaltung:

![admin_orders_bestellung-anpassen.png](/uploads-de/admin_orders_bestellung-anpassen.png)

Es können auch **Kommazahlen** bei *Bekommen* eingeben werden. 
- Beispiel oben: 2 Bestellgruppen haben je 2 kg Äpfel bestellt, wobei 1 Bestelleinheit gleich 1 kg ist. Geliefert wurde insgesamt  4,7 statt 4 kg. Lager erhält 2,2 kg und Anton 2,5 kg. 

> Die Beträge müssen immer mit Dezimalpunkt statt -komma eingegeben werden, auch wenn sie daraufhin mit Dezimalkomma angezeigt werden.
{.is-warning}

> Die Anpassungen werden erst gespeichert, wenn du auf *in Empfang nehmen* klickst!
{.is-warning}

Im Abrechnungsmenü sieht es folgendermaßen aus:

![abrechnung.png](/uploads-de/abrechnung.png)



Die veränderte Bestellmenge wird in den Bestelllisten berücksichtigt (Bestellt => *Bekommen*, *Preis* entspricht Menge *Bekommen*), sofern sie nach der Anpassung erstellt bzw. ausgedruckt werden:

![admin_orders_bestellung-anpassen-pdf.png](/uploads-de/admin_orders_bestellung-anpassen-pdf.png)

Den Bestellgruppen wird dann die tatsächlich erhaltene Menge bei der Abrechnung abgebucht.

Es können hier nur Umverteilungen eingegeben werden, das heißt es muss die folgende Reihenfolge eingehalten werden:
1. *Bestellung in Empfang nehmen*, dort die gesamt erhaltene Menge pro Artikel eingegeben werden
2. Aufteilung auf die Bestellgruppen anpassen. Die vorher eingestellte gesamt Menge muss dabei erhalten bleiben.
> Die Funktion *in Empfang nehmen* überschreibt eventuelle vorher eingegebene Umverteilungen von Artikeln auf die Bestellgruppen mit den ursprünglich bestellen Mengen. Die gesamt empfangene Menge kann nach einer Umverteilung auf die Bestellgruppen nur mehr über *Finanzen > Bestellungen abrechnen > Artikel bearbeiten* angepasst werden.
{.is-warning}


> In der Bestellverwaltung können nur die Mengen für Bestellgruppen verändert werden, die auch etwas bestellt haben. Bestellgruppen, die nichts bestellt haben, scheinen nicht auf. Wenn zum Beispiel zu viel geliefert wird, und eine Bestellgruppe etwas davon übernehmen möchte, die nichts bestellt hat, kann unter *Finanzen > Bestellungen abrechnen* diese  Bestellgruppe hinzugefügt werden. 
{.is-info}




<!-- DIESEN ABSCHNITT NACH FINANZEN > BESTELUNNG ABRECHNEN VERSCHIEBEN! (Mirko)

Der Vorgang „Bestellung abrechnen“ erfolgt in zwei Stufen, die – leider etwas verwirrend – gleich heißen:

1. **Bestellung zur Abrechnung vorbereiten**: In der Liste “Finanzen \> Bestellung abrechnen” bei der entsprechenden Bestellung auf „abrechnen“ oder den Datumslink klicken. In diesem Schritt bereitest du die Bestellung zur Abrechnung vor, indem du  noch Änderungen an der     Bestellung vornehmen kannst, wie unten beschrieben. Alle Änderungen an der Bestellung werden automatisch gespeichert (keine „Abbrechen“ Funktion\!), es wird aber das Guthaben der Bestellgruppen noch nicht belastet. Du kannst auch öfters zurückkehren und weitere Änderungen vornehmen, solange du nicht den 2. Schritt ausgeführt hast.
2. **Bestellung endgültig abrechnen**: Auf der Seite von Schritt 1 gibt es nochmals die Schattfläche „Bestellung abrechnen“, mit der die Bestellung dann endgültig abgerechnet wird. Damit werden den Bestellgruppen die entsprechenden Beträge von ihrem Guthaben endgültig abgezogen, die Bestellung kann nicht mehr verändert werden, und diese Bestellung kann auch keiner Rechnung mehr zugeordnet werden. 

> *Folgende Schritte überarbeiten...*
{.is-danger}


Unter “Finanzen \> Bestellung abrechnen”: 
- **Bestellte Anzahl an gelieferte anpassen** (mehr oder weniger Artikel als bestellt wurden geliefert): *Bestellung bearbeiten \> Titel des Artikels anklicken \> Im Aufklappmenü Menge bei den Gruppen entsprechend ändern* ODER *Gruppenansicht \>* Anpassen der gelieferten Menge, wenn diese von der Bestellung abweicht
 - **Neue Bestellgruppe(n) hinzufügen** (es wurde z.B. ein Alternativartikel für nicht gelieferte Produkte geliefert): Bestellung bearbeiten \> Titel des Artikels anklicken \> Im Aufklappmenü “Gruppe hinzufügen”, Anzahl eingeben, bei Bedarf (mehrere Gruppen betroffen) Schritt wiederholen

Es können auch **Kommazahlen** bei *Bekommen* eingeben werden. 

Das kann genützt werden, um Artikel mit schwankendem Gewicht bzw. Preis abzurechnen:

> **Beispiel: tatsächliches Gewicht bekannt**:
>
>Bestellt werden 2 Stück Krautkopf, in der Foodsofthinterlegt zu je 3,00 € für 2 kg/Stück und 1,50 € pro kg, also gesamt 6,00 €. Bekommen und mit der Waage abgewogen: 1,8 kg und 2,5 kg = gesamt 4,3 kg
> - Umrechnung in Stück: 4,3 kg / 2 kg pro Stück = 2,15 Stück
> - Preis wird automatisch zu 2,15 \* 3,00 € = 6,45 € berechnet


> **Beispiel: tatsächliche Kosten bekannt** 
>
> Bestellt werden 2 Stück Käse, in der Foodsoft hinterlegt zu je 10,00 € für 500 g/Stück und 20 € pro kg, also gesamt 20,00 €
> - Bekommen: laut Etiketten kosten die Käse 9,50 € und 9,10 € = gesamt 18,60 €
> - Umrechnung in Stück: 18,60 € / 10 € pro Stück = 1,86 Stück
> - Preis wird automatisch zu 1,86 * 10,00 € = 18,60 € berechnet


> Zusätzlich muss über *Lieferung in Empfang nehmen* die Gesamtmenge angepasst werden, damit die Abrechnung stimmt.
{.is-info}

> Beispiel aus https://forum.foodcoops.at/t/neue-funktionen-in-der-foodsoft/4847/5 hier übernehmen!
{.is-danger}
-->

## Artikeleigenschaften anpassen

Manchmal ändern sich z.B. Artikelpreise zwischen Bestellung und Lieferung und müssen in der bereits abgeschlossenen, aber noch nicht abgerechneten Bestellung korrigiert werden, damit sie der Rechnung entsprechen. Unter *Finanzen > Bestellungen abrechnen* kannst du jeden Artikel bearbeiten:

- Der Preis ist die einzige Artikeleigenschaft, die für jeden Artikel und jede Bestellung separat abgespeichert wird. Dadurch wirken sich Preisänderungen eines Artikels in einer Bestellung zunächst nicht auf andere Bestellungen aus: 
  - Bei vergangenen Bestellungen soll das ja immer so sein. 
  - Für zukünftige Bestellungen kannst du über die Option „Globalen Preis aktualisieren“ den Preis auch in der Artikelliste der Lieferantin ändern. Wird diese Option nicht angewählt, wird die Änderung nur für die aktuelle Bestellung übernommen und der Preis in der Artikelliste der Lieferantin bleibt unverändert.
  - Alle anderen Artikeleigenschaften wie Name, Einheit usw. können nur global verändert werden, sie ändern sich also sowohl bei vergangenen Bestellungen als auch in der Artikellliste der Lieferantin und damit auch in zukünftigen Bestellungen.

Nur wenn Artikel mit veränderten Eigenschaften in der Artikelliste der Lieferantin als neue Artikel angelegt werden (anstatt die bestehenden zu bearbeiten), werden die Eigenschaften der Artikel in früheren Bestellungen nicht beeinflusst. Die veränderten Artikel sind dann allerdings auch erst bei zukünftig neu angelegten Bestellungen verfügbar. 


## Transportkosten hinzufügen

> Für diese Funktion ist die Berechtigung *Finanzen* erforderlich!
{.is-warning}

Manche ProduzentInnen verrechnen pro Lieferung Transportkosten, manchmal auch abhängig von der Bestellsumme. So können die tatsächlich angefallenen Transportkosten für jede Bestellung im Nachhinein gerecht auf alle Bestellgruppen aufgeteilt werden:


1. *Finanzen > Bestellungen abrechnen*
2. Bestellung auswählen
3. rechts oben *Artikel hinzufügen > Transportkosten bearbeiten* 

![admin_finances_order_transportkosten_bearbeiten1.png](/uploads-de/admin_finances_order_transportkosten_bearbeiten1.png)

4. Gesamte Transportkosten für Bestellung eingeben (auch negativer Betrag möglich, falls z.B. zu viel bereits in die Artikelpreise einkalkulierte Transportkosten abgezogen werden sollen)

![admin_finances_order_transportkosten_bearbeiten2.png](/uploads-de/admin_finances_order_transportkosten_bearbeiten2.png)

5. Transportkostenverteilung auswählen:
   1. Kosten nicht auf die Bestellgruppen aufteilen
   2. Jede Bestellgruppe zahlt gleich viel
   3. Kosten anhand der Bestellsumme aufteilen
   4. Kosten anhand der Anzahl an erhaltenen Artikeln verteilen 
6. Speichern
7. *Ansichtsoptionen > Gruppenübersicht*: Anteil an Transportkosten für jede Bestellgruppe wird angezeigt
8. Solange die Bestellung noch nicht abgerechnet wurde, kann der Vorgang ab Schritt 3 wiederholt werden, um Korrekturen vorzunehmen, nachdem die Ansichtsoption wieder auf *Bestellung bearbeiten* zurückgesetzt wurde.

> Wenn die Bestellung über *Finanzen > Bestellungen abrechnen* verändert wird, müssen die Transportkosten neu berechnet werden, da sie nicht automatisch angepasst werden.
{.is-info}

> Wie die Transportkosten bei der Anzeige von Rechnungen berücksichtigt werden, findest du unter [Rechnungen](/de/documentation/admin/finances/invoices).
{.is-info}


> Der Fehler, dass seit März 2021 Transportkosten den Mitgliedern beim Abrechnen nicht von ihren Konten abgebucht wurden (siehe https://github.com/foodcoops/foodsoft/issues/861), wurde am 20.10.2021 behoben. Transportkosten, die in diesem Zeitraum angelegt wurden, müssen vor dem Abrechnen der Bestellung nochmal bearbeitet werden, damit sie beim Abrechnen korrekt berücksichtigt werden. Die Transportkosten von bereits abgerechneten Bestellungen können nur über manuelle Kontobuchungen nachträglich berücksichtigt werden.
{.is-success}


# Bestellung abrechnen

Beim Bestellen werden die Beträge den Bestellgruppen noch nicht von ihren Konten abgebucht, es verringern sich zunächst nur die verfügbaren Guthaben. Erst beim Abrechnen einer Bestellung werden die Beträge für diese Bestellung den Bestellgruppen von ihren Foodsoft-Konten abgebucht. Nur vorher können noch Anpassungen durchgeführt werden, wenn es z.B. bei der Lieferung Abweichungen zur Bestellung gibt. Weiters sollte die Rechnung des Produzenten angelegt und mit der Bestellung verknüpft werden, um vergleichen zu können, ob sich die Geldbeträge von Rechnung und Bestellung decken.

Die Bestellung sollte erst abgerechnet werden, wenn auch die [Rechnung](/de/documentation/admin/finances/invoices) angelegt und idealerweise auch bezahlt oder zumindest zur Bezahlung freigegeben wurde.

> Sobald eine Bestellung abgerechnet wurde, kann keine Rechnung mehr für
> diese Bestellung angelegt werden. Es kann zwar eine Rechnung erstellt
> werden, aber die bereits abgrechnete Bestellung kann nicht mehr ausgewählt werden, um mit der Rechnung verknüpft zu werden.
{.is-warning}

> In der .at-Testinstanz [foodsoft-demo](/de/documentation/admin/foodsoft-demo) ist möglich, auch nach abgerechneter Bestellung noch eine  Rechnung dazu anzulegen (2.10.2021 Mirko)
{.is-success}

Die Foodsoft-Funktion  „Bestellung abrechnen“ erfolgt in zwei Stufen, die – leider etwas verwirrend – gleich heißen:

1. **Bestellung zur Abrechnung vorbereiten**: Anpassung der Bestellung durchführen (tatsächlich erhaltene Artikelzahlen, gegenüber Bestellung abweichende Verteilung an Bestellgruppen, geänderte Artikelpreise, Transportkosten hinzufügen, ...) 
2. **Bestellung endgültig abrechnen**: Auf der Seite von Schritt 1 gibt es nochmals die Schattfläche *Bestellung abrechnen*, mit der die Bestellung dann endgültig abgerechnet wird. Damit werden den Bestellgruppen die entsprechenden Beträge von ihrem Guthaben endgültig abgezogen, die Bestellung kann nicht mehr verändert werden. 

## Bestellung zur Abrechnung vorbereiten

In der Liste *Finanzen > Bestellung abrechnen* bei der entsprechenden Bestellung auf *abrechnen* oder den Datumslink klicken. In diesem Schritt bereitest du die Bestellung zur Abrechnung vor, indem du  noch Änderungen an der     Bestellung vornehmen kannst. Alle Änderungen an der Bestellung werden automatisch gespeichert (keine *Abbrechen* Funktion!), es wird aber das Guthaben der Bestellgruppen noch nicht belastet. Du kannst auch öfters zurückkehren und weitere Änderungen vornehmen, solange du nicht den 2. Schritt *Bestellung (endgültig) abrechnen* ausgeführt hast.

Es wird zunächst nur eine Liste aller bestellten Artikel angeiegt und die gesamten Kosten der Artikel. Wenn du auf den Namen eines Artikels klickst, erscheinen bzw. verschwindet eine Liste der Bestellgruppen, die diesen Artikel bestellt haben, mit der jeweiligen Artikelanzahl *Bekommen*. In der ersten Zeile findest du eine Schaltfläche *Gruppe hinzufügen*, falls eine Bestellgruppe etwas erhalen hat, ohne etwas bestellt zu haben.

Die *Bekommen* Anzahl kannst du verändern über die +/- Tasten, oder indem du eine Zahl eingibst. Es können auch **Kommazahlen** bei *Bekommen* eingeben werden. Das kann genützt werden, um Artikel mit schwankendem Gewicht bzw. Preis abzurechnen:

> **Beispiel: tatsächliches Gewicht bekannt**:
>
>Bestellt werden 2 Stück Krautkopf, in der Foodsofthinterlegt zu je 3,00 € für 2 kg/Stück und 1,50 € pro kg, also gesamt 6,00 €. Bekommen und mit der Waage abgewogen: 1,8 kg und 2,5 kg = gesamt 4,3 kg
> - Umrechnung in Stück: 4,3 kg / 2 kg pro Stück = 2,15 Stück
> - Preis wird automatisch zu 2,15 \* 3,00 € = 6,45 € berechnet


> **Beispiel: tatsächliche Kosten bekannt** 
>
> Bestellt werden 2 Stück Käse, in der Foodsoft hinterlegt zu je 10,00 € für 500 g/Stück und 20 € pro kg, also gesamt 20,00 €
> - Bekommen: laut Etiketten kosten die Käse 9,50 € und 9,10 € = gesamt 18,60 €
> - Umrechnung in Stück: 18,60 € / 10 € pro Stück = 1,86 Stück
> - Preis wird automatisch zu 1,86 * 10,00 € = 18,60 € berechnet


> Wenn sich durch die Anpassung der Aufteilung eines Artikels die Gesamtzahl ändert, muss zusätzlich entweder vor den Anpassungen über *Bestellungen > Bestellverwaltung > Bestellung in Empfang nehmen* die Gesamtmenge angepasst werden, oder im Nachhinein über *Artikel Bearbeiten* in der Abrechnungsansicht, damit die Abrechnung stimmt.
{.is-warning}



## Bestellung endgültig abrechnen

1. Menü *Finanzen > Bestellungen abrechnen*
1. Abzurechnende Bestellung aus der Liste suchen, in dieser Zeile den Link der Lieferantin oder "abrechnen" anklicken
1. *Bestellung abrechnen*
1. Bestätigen (kein Zurück!)

# Bestellung löschen

Eine Bestellung sollte nur dann gelöscht werden, wenn sie versehentlich angelegt wurde und idealerweise noch nichts bestellt wurde. 

> Ist es möglich, eine offene Bestellung zu löschen, bei der schon etwas bestellt wurde?
{.is-danger}

> Erfolgreich abgewickelte Bestellungen sollten keinesfalls gelöscht werden, sondern für Buchhaltung und Nachvollziehbarkeit erhalten bleiben.
{.is-warning}


> Wenn eine Bestellung schon beendet ist, die Lieferung aber nicht zustande kommt (z.B. weil die Mindestbestellmenge nicht erreicht wurde), ist es besser, mit Hilfe der Funktion "Lieferung in Empfang nehmen" alle empfangenen Mengen auf Null zu setzten (ein Klick), statt die Bestellung zu löschen. Damit wird den Mitgliedern nichts von ihrem Guthaben abgebucht, es scheint in den Bestelllisten aber "bestellt: X, bekommen: 0" auf, sodass die Bestellung nicht einfach "verschwindet", sondern ersichtlich ist, dass sie nicht zustandegkommen ist.
{.is-info}

