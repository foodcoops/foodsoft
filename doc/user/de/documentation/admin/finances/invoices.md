---
title: Rechnungen
description: Rechnungen von Lieferantinnen digital ablegen, mit Bestellungen verknüpfen und Bezahlstatus
published: true
date: 2025-05-29T23:55:39.713Z
tags: 
editor: markdown
dateCreated: 2021-04-20T23:05:17.349Z
---

Die Funktion “Rechnung” dient dazu, Rechnungen von Produzentinnen in die Foodsoft zu übertragen (sozusagen eine digitale Kopie der Rechnung anzulegen), und sie mit den entsprechenden Lieferungen und Bestellungen zu verknüpfen. Das ermöglicht es,
- die Rechnungsdaten in der Foodsoft digital zu sammeln und jederzeit abrufbar zu haben (statt oder zusätzlich zu einem Papierrechnungsordner)
- vergleichen zu können, ob den Bestellgruppen auch genauso viel von ihren Konten abgebucht wird, wie die Rechnung ausmacht - die einzige Möglichkeit, einer exakten Bilanzierung;
- die Verarbeitung von Rechnungen aufteilen zu können auf unterschiedliche Personen in die Schritte *Rechnungsdaten eingeben* und *Rechnung bezahlen*.

Die Rechnungen der Produzentinnen können dabei in Papierform oder digital als PDF oder JPG vorliegen. Rechnungen scheinen in der Foodsoft zunächst in der Liste der *unbezahlten Rechnungen* auf, und werden als bezahlt markiert, sobald ein entsprechender Zahlungsausgang am Foodsoft-Bankkonto auftritt, wenn das [Bankkonto mit der Foodsoft verknüpft](/de/documentation/admin/finances/bank-accounts) ist. Dadurch wird es möglich, dass mehrere Personen in der Foodcoop Rechnungen vorbereiten, und z.B. eine Person mit Bankzugang dadurch weniger Aufwand beim Einzahlen der Rechnungen hat. Gleichzeitig ist in der Foodsoft jederzeit für alle Beteiligten (Berechtigung *Finanzen*) ersichtlich, welche Rechnungen noch zu bezahlen sind.

> Weiters ist eine Funktion in der Testphase, dass Rechnungen aus der Foodsoft heraus bezahlt werden können, indem sich die Foodsoft mit dem Bankkonto verbindet und einen Zahlunsgauftrag anlegt. 
{.is-info}


# Erforderliche Berechtigungen

Mit der Berechtigung **Rechnungen** können Benutzerinnen
- Rechnungen anlegen und 
- alle Rechnungen sehen, aber 
- nur die selbst angelegten Rechnungen bearbeiten, solange die Rechnung noch nicht bezahlt ist

Mit der Berechtigung **Finanzen** können Benutzerinnen
- alle Rechnungen bearbeiten, egal von wem sie angelegt wurden
- Rechnungen auch dann noch bearbeiten, wenn sie schon bezahlt ist.


# Rechnung anlegen


Eine neue Rechnung kann angelegt werden unter
- *Finanzen \> Rechnungen \> Neue Rechnung anlegen*
- *Finanzen \> Bestellungen abrechnen \> Bestellung auswählen \> Rechnung anlegen*
- *Bestellverwaltung \> beendete Bestellung auswählen \> Rechnung anlegen*
- *Artikel \> Lieferant \> Bestellung \> Rechnung anlegen*
- *Artikel \> Lieferant \> Letzte Lieferungen \> Rechnung anlegen*
- *Artikel \> Lager \> neue Lieferung ... > Rechnung anlegen*

> Empfehlung: Rechnungen, die in Papierform vorliegen, gehen einfacher mit einem Smartphone oder Tablet mit Kamerafunktion einzugeben. Sobald ein Rechnungsdatum eingegeben ist, kann die Eingabe jederzeit unterbrochen, die Rechnung unfertig gespeichert werden, um auf einem anderen Gerät fortgesetzt werden. Wichtig ist es, vor dem Speichern bei **Rechnungsdatum** das Datum der Rechnung (oder zumindest das aktuelle Datum) einzugeben, weil sie sonst schwer auffindbar ist. 
{.is-info}

Hier ein Beispiel für eine Papierrechnung und die entsprechenden Eingaben in der Foodsoft, wie im Folgenden im Detail beschrieben.

![rechnung-beispiel-fs.png](/uploads-de/admin_finances_invoices_rechnung-beispiel-fs.png)

In der neuen Rechnung ist anzugeben:

## Lieferant

Lieferantin auswählen.

> Wenn die Liste der Lieferantinnen recht lang ist, kannst du den ersten Buchstaben der Lieferantin tippen, um sie schneller zu finden.
{.is-info}


## Bestellungen und Lieferungen mit Rechnung verknüpfen

In den Feldern **Lager-Lieferung** und **Bestellung** solltest du jene Lager-Lieferung(en) und/oder jene Bestellung(en) auswählen, für die die Rechnung ausgestellt wurde. Damit ist klar, ob die Lieferantin für eine Lieferung/Bestellung eine Rechnung ausgestellt hat, und der Rechnungsberag kann mit dem Guthaben, das den Mitgliedern abgebucht wird (bzw. das als Warenwert ins Lager eingegangen ist), verglichen werden. Dies ist die einzige echte Kontrollmöglichkeit, um zu schauen, dass die Foodcoop keinen Verlust, aber auch keinen unerwünschten Gewinn macht - daher ist dieser Schritt sehr wichtig.

![rechnung-bestellung-lieferung.png](/uploads-de/admin_finances_invoices_rechnung-bestellung-lieferung.png =400x)
    
-  **[Lager-Lieferung](./Lager)**: **bei Rechnung für eine Bestellung leer lassen**. Wenn für diesen Produzenten [Lagerartikel](./Lager) über die Funktion *Artikel > Lager > neue Lieferung* eingebucht  wurden, die noch keiner Rechnung zugeordnet sind, können diese  hier ausgewählt werden. Mehrere Lieferungen können dabei in  einer gemeinsamen Rechnung ausgewählt werden.
-  **[Bestellung](./Bestellung)**: wenn es für diesen Produzenten abgeschlossene, aber noch nicht abgerechnete Bestellungen gibt, die noch keiner Rechnung zugeordnet sind, können diese hier ausgewählt werden. Mehrere Bestellungen können dabei in einer gemeinsamen  Rechnung ausgewählt werden.
    
> Angezeigter **Betrag** für Bestellung(en) und Lieferung(en)
> ist der Bruttobetrag (inkl. Mwst und Pfand)
{.is-info}

    
> Angezeigtes **Datum** für Bestellung(en) und Lager-Lieferung(en) ist jenes, an dem die Bestellung endete (nicht Liefer- oder  Abholdatum\!)
{.is-info}

> Es können mehrere Bestellungen und/oder Lager-Lieferungen ausgewählt werden, wenn dafür von der Lieferantin eine gemeinsame Rechnung gestellt wurde.
{.is-info}

> Es werden **maximal 25** nicht zugeordnete **Bestellungen** bzw. Lager-Lieferungen(?) **zur Auswahl** angezeigt. Wenn du ältere Bestellungen nicht in der Auswahlliste siehst, beginne zuerst, Rechnungen für neuere Bestellungen zu erstellen. Sobald diese zugeordnet sind, werden Anzeigeplätze frei und die ältern "rutschen nach".
{.is-warning}


> Eine Bestellung oder Lager-Lieferung kann **nur einmal einer Rechnung zugeordnet** werden: Sobald eine Bestellung oder Lieferung einer Rechnung zugeordnet wurde, scheint sie bei anderen Rechnunge nicht mehr zur Auswahl auf. Wenn schon eine Rechnung angelegt und Bestellungen und/oder Lager-Lieferungen zugeordnet wurden, daher unbedingt diese suchen (siehe Rechnungsdatum) und bearbeiten, statt sie nochmal neu anzulegen. Falls eine Bestellung oder Lieferung versehentlich einer falschen Rechnung zugeordnet wurde, kann diese Rechnung bearbeitet, und dort die Bestellung oder Lieferung weggenommen werden, dann sollte sie bei der richtigen Rechnung wieder auswählbar sein.
{.is-warning}

> Auch eine bereits **abgerechnete Bestellung** kann einer Rechnung zugeordnet werden. Empfohlen wird jedoch, zuerst die Rechnung anzulegen, mit der Bestellung zu vergleichen, und dann erst die Bestellung abzurechnen.
{.is-success}


> Wenn eine Bestellung neben den Bestellungen für die Foodcoop Mitglieder auch eine **Lagerbestellung** enthält, und diese Lagerartikel dann mit einer Lieferung in den Lagerstand eingebracht werden, und sowohl die Bestellung als auch die Lieferung der Rechnung korrekter weise zugeordnet wird, würden sie bei der Rechnungsbilanz doppelt berücksichtigt - siehe [Lager](/de/documentation/admin/storage)
**Anschauen in Demoinstanz**: Bestellung, Bestellung+Lager,  Bestellung+Lager+Lieferung, Bestellung+Lieferung, Lieferung - was wird jeweils bei *Total* berücksichtigt und was bei der Differenz in *Unbezahlte Rechnungen?*
{.is-danger}


## Nummer

Rechnungsnummer von Rechnung übernehmen. Die Rechnungsnummer wird bei der Banküberweisung von der Foodsoft (oder von der Person, die in der Foodcoop die Rechnungen via Ebanking manuell bezahlt) in den Verwendungszweck eingetragen, und dient sowohl der Foodsoft als auch der Lieferantin zur eindeutigen Zuordnung der Rechnung. 

> Das Feld *Rechnungsnummer* ist ein Textfeld und kann neben Zahlen auch Buchstaben und Leerzeichen enthalten.
{.is-success}

> Das Feld *Verwendunsgzweck* in Banküberweisungen, für das bei automatisierten Überweisungen die Rechnungsnummer übernommen wird, erlaubt neben Groß- und Kleinbuchstaben nur die Zeichen `, & - / + * $ %`, sowie `ÄÖÜß` und die Ziffern von `0-9`, nicht jedoch andere Sonderzeichen (wie z.B. `# ;`). Enthält die Rechnungsnummer unzulässige Zeichen, kann es beim Bezahlen der Rechnung passieren, dass die Bank-App die Überweisung ablehnt.
{.is-warning}


> Falls auf der Rechnung keine Rechnungsnummer aufscheint, selbst eine (in Bezug auf die Lieferantin) eindeutige Rechnungsnummer erstellen, z.B. aus dem Datum, also z.B. `20210527` oder `2021-05-27` oder `270521` oder `27.5.2021`. Im Gegensatz zum Feld *Rechnungsdatum* ist hier das Datumsformat egal, weil die Rechnungsnummer nur ein Textfeld ist, und die Foodsoft die Eingabe nicht als Datum interpretiert. 
{.is-info}

> Falls die Lieferantin z.B. bei **Vorauszahlung** einen bestimmten **Verwendungszweck** benötigt, diesen als Rechnungsnummer eintragen. 
{.is-info}

> Falls die Zahlung per **Lastschrift** erfolgt, den Verwendungszweck der Buchung nach erfolger Abbuchung vom Foodcoop-Bankkonto (gegebenenfalls nachträglich) als Rechnungsnummer eingeben, damit die Buchung der Rechnung zugeordnet wird und die Rechnung als bezahlt markiert wird.
{.is-info}





## Rechnungsdatum

Von Rechnung übernehmen. Wenn nicht bekannt, das Datum der Lieferung (eruierbar z.B. aus der ausgewählten Bestellung) oder das aktuelle Datum eingeben.

Für die Eingabe des Datums gibt es folgende alternative Möglichkeiten:

![admin_finances_invoices_date.png](/uploads-de/admin_finances_invoices_date.png)

1. Über die **Kalenderfunktion**: ins Eingabefeld klicken, es erscheinent ein Kalender, das aktuelle Datum ist gelb hinterlegt. Auf das gewünschte Datum klicken, wodurch dieses blau wird und im Eingebefeld erscheint. Diese Art ist auf mobilen Geräten aufgrund des kleinen Displays oft schwierig anzuwenden. 
1. **Eingabe im Textfeld genau im Format** `2021-09-30` (also zuerst Jahr 4-stellig, Bindestrich, in der Mitte Monat zweistellig ggf. mit führender Null, Bindestrich, am Ende Tag zweistellig ggf. mit führender Null). 

> Wenn das Datum im falschen Format eingegeben wird, interpretiert die Foodsoft das Datum und insbesondere das Jahr falsch, und die Rechnung ist nachher scheinbar verschwunden, weil die Rechnungen nach Datum sortiert werden (neuerste zuerst). Die Eingabe von `30.9.2021` ergibt z.B. `36-03-13`, also das Datum 13. März im Jahr 36 n.Chr., und die Rechnung wird ganz ans Ende der Liste gereiht.
{.is-warning}


> Auch wenn dieses Feld leer gelassen wird, erscheint die Rechnung ganz am Ende der Liste der Rechnungen, statt am Anfang, wo neue Rechnungen sonst zu finden sind. 
{.is-warning}



## Bezahlt am

### Rechnung noch unbezahlt

**Leer lassen**, wenn die Rechnung noch nicht bezahlt wurde. Die Rechnung scheint in der Foodsoft in der Liste "unbezahlte Rechnungen" auf. Die Person in deiner Foodcoop, die einen Bankkontozugang hat und die Überweisung der Rechnungen durchführt, weiß damit, dass diese Rechnung zu zahlen ist.  Wenn das Bankkonto der Foodcoop mit der Foodsoft verbunden ist, wird die Foodsoft hier automatisch das Datum des Zahlungsausgangs eintragen, und die Rechnung ist dann damit als bezahlt gekennzeichnet werden.

### Rechnung bereits bezahlt

Falls die Rechnung schon bezahlt wurde, das Datum eintragen, an dem dies erledigt wurde. Die Rechnung scheint dann **nicht** unter "unbezahlte Rechnungen" auf.  Die Person in deiner Foodcoop, die einen Bankkontozugang hat und die Überweisung der Rechnungen durchführt, weiß damit, dass diese Rechnung nicht mehr zu zahlen ist.


## Betrag

Rechnungsbetrag (inklusive [Mehrwertsteuer](/de/documentation/admin/finances/value-added-tax)) von der Rechnung übernehmen. Als Dezimaltrennzeichen kann dabei Komma oder Punkt verwendet werden, also für eine Rechnungssumme von z.B. 1.257,87 € entweder `1257,87` oder `1257.87` - angezeigt wird der Betrag dann in Folge mit einem Punkt als Dezimaltrennzeichen.

## Pfand berechnet

Leer lassen, falls in den Artikeln der Foodsoft ein Pfandbetrag bereits inkludiert ist, weil Bestellungen und Lieferungen nicht pfandbereinigt werden. Falls sich Pfand in der Foodsoft und auf der Rechnung des Produzenten nicht decken, kann hier die Differenz eingegeben werden: 
- `Pfand gesamt Produzent` - `Pfand gesamt Foodsoft`. 
    
    
### Beispiele

Für 3 Flaschen und 50 Cent Pfand pro Flasche:
- Foodsoft-Artikel enthält 50 Cent Pfand pro Flasche, Produzent verrechnet ebenfalls 50 Cent pro Flasche, Differenz = 3 \* 0,50 - 3 \* 0,50 = **0 €**
- Foodsoft-Artikel enthält 50 Cent Pfand pro Flasche, Produzent verrechnet nur 10 Cent pro Flasche, Differenz = 3 \* 0,10 - 3 \* 0,50 = 3 \* (0,10-0,50) = **-1,20 €**
- Foodsoft-Artikel enthält 50 Cent Pfand pro Flasche, Produzent verrechnet kein Pfand, Differenz = 0 - 3 \* 0,50 = **-1,50 €** 
- Foodsoft-Artikel enthält kein Pfand, Produzent verrechnet 50 Cent pro Flasche, Differenz = 3 \* 0,50 - 0 = **+1,50 €**

> Allgemeines zu Pfand siehe [Pfand in Foodcoops](/de/documentation/admin/finances/deposits)
{.is-info}


## Pfand gutgeschrieben

Pfandgutschrift des Produzenten Brutto (inkl. Mwst) **als positiven Wert** eintragen wie auf der Rechnung ausgewiesen, sofern im Rechnungsendbetrag berücksichtigt.

> Manche Lieferantinnen führen die Pfandgutschrift netto an. In diesem Fall musst du die Mehrwertsteuer noch dazurechnen. 
{.is-warning}


> Kann auch  für andere Gutschriften (z.B. Skonto) verwendet werden, die in den   Foodsoft-Bestellungen nicht berücksichtigt sind.
{.is-info}


## Anhang

Foto der Papierrechnung im JPEG Format oder PDF-Rechnungsdatei hochladen. Es kann nur eine Datei pro Rechnung hochgeladen werden. 

Falls die Rechnung aus mehreren Seiten bzw. Dokumenten besteht, müssen diese vorher zu einer Datei zusammengfügt werden. Tipps für Programme, mit denen das geht:
- PDF-Dateien 
  - https://pdfsam.org/
- JPEG-Bilder 
  - alle Seiten auf einmal fotografieren
  - im Bildbetrachter mehrer Bilder in eine PDF-Datei drucken (Drucker *in Datei drucken* auswählen)
  - https://imagemagick.org/ Kommandozeilenbefehl Beispiel für Zusammenfügen von 3 Bildern nebeneinander (3x1) in Originalgröße (100%): `montage -geometry 100% -tile 3x1 img1.jpg img2.jpg img3.jpg merged.jpg`
    
> Auf Smartphones oder Tablets kann oft direkt die Kamera das Geräts ausgewählt und eine Foto der Rechnung aufgenommen und hochgeladen werden. 
{.is-info}


## Notiz

Hier kannst du einen beliebigen Text als Kommentar zur Rechnung eingeben. Dieser Text wird in der Liste der unbezahlten Rechnungen (in Klammern) angezeigt. 

Empfohlen wird, dass hier der Status der Rechnung kommentiert wird (*"kann bezahlt werden"*, oder *"es muss  noch auf eine Anpassung an die Lieferung gewartet werden"*) und etwaige Differenzen zwischen Bestellung und Rechnung dokumentiert und erklärt werden (Vorschlag: *“Differenz X,XX Euro zugunsten/zulasten der Foodcoop aufgrund ...”*). 

> Das Feld kann zunächst leer gelassen und später noch bearbeitet werden.
{.is-info}

## Rechnung erstellen

Nachdem du auf *Rechnung erstellen* geklickt hast, werden alle Eingaben nochmal zusammengefasst dargstellt. Kontrolliere nochmal das Rechnungsdatum, jetzt ist die letzte Chance, es noch zu korrigieren, bevor die Rechnung dann in der Liste der Rechnungen "untertaucht", wenn sie ein falsches Datum hat. Was die anderen dargstellten Daten genau bedeuten, erfährst du unten unter *Rechnung prüfen*.



# Sonderfälle

## Transportkosten

Wenn die Rechnung extra ausgewiesene Transportkosten enthält, können diese auf die Bestellung aufgeschlagen werden, sodass die Transportkosten auch von den Bestellgruppen anteilsmäßig übernommen werden. Siehe [Bestellungen > Transportkosten](/de/documentation/admin/orders).


## Abweichender Betrag
Wenn ein anderer Betrag als jener auf der Rechnung zu bezahlen ist, dann soll dieser abweichende Betrag unter *Betrag* eingegeben werden. Das kann z.B. vorkommen, wenn der Lieferantin in der Rechnung ein Fehler passiert ist, und es zusätzlich zur Rechnung eine Gutschrift gibt. Dann sollten Sowohl Rechnung als auch Gutschrift im Anhang zur Rechnung hochgeladen werden.

> Siehe oben bei *Rechnung anlegen > Anhang* wie mehrere Dateien zu einer verbunden werden können.
{.is-info}

## Mehrteilige Rechnung
Wenn für eine Bestellung mehrere Rechnungen ausgestellt werden, ist es sinnvoll, in der Foodsoft nur eine gemeinsame Rechnung anzulegen. 
- Bei *Rechnungsnummer* werden dann alle Nummern der einzelnen Rechnungen eingetragen (z.B. `20210045, 20210046`), 
- bei *Betrag* die Summe der Rechnungen, 
- bei *Anhang* die in einer gemeinsamen Datei vereinten Einzelrechnungen 

> Siehe oben bei *Rechnung anlegen > Anhang* wie mehrere Dateien zu einer verbunden werden können.
{.is-info}

## Zahlung per Einzieher (SEPA Lastschrift)

Manche Lieferantinnen ziehen ihre Rechnungsbeträge selbständig vom Foodcoop Bankkonto per Lastschrift ab. Auch für diese Zahlungen sollten in der Foodsoft Rechnungen angelegt werden. In der *Notiz* kann vermerkt werden, dass diese Rechnungen nicht per Überweisung bezahlt werden sollen, weil sie automatisch beglichen werden. Die *Rechnungsnummer* in der Foodsoft muss an den Verwendungszweck der Lastschriftbuchung angepasst werden, damit ein Finanzlink zwischen Buchung und Rechnung angelegt und die Rechnung als bezahlt markiert wird (siehe [Foodsoft mit Bankkonto verknüpfen](/de/documentation/admin/finances/bank-accounts)).

> Die Rechnung in der Foodsoft kann vor und nach der erfolgten Abbuchung vom Bankkonto angelegt werden. Oft sind die Rechnungsdaten wie Betrag und Rechnungsnummer erst nach der Abbuchung bekannt. Die Rechnung kann trotzdem auch schon vorher mit vorläufigen Daten angelegt werden, und dann nach der Abbuchung noch angepasst werden. Nach der ersten Abbuchung muss gegebenenfalls die IBAN der Lieferantin in der Foodsoft an die IBAN der Buchung angepasst werden.
{.is-info}


# Rechnung anzeigen und bearbeiten

## Rechnung anzeigen
Um eine bereits angelegte Rechnung anzuzeigen: 
- *Finanzen \> Rechnungen*: Die Rechnungen sind nach Rechnungsdatum sortiert, beginnend mit aktuellen. Diese Rechnung sollte hier auch dann zu finden sein, wenn die Rechnung schon als bezahlt markiert wurde (= Datum bei "bezahlt am" eingegeben)
>  Wenn ein falsches Datum in der   Vergangenheit eingegeben wurde, kann es sein, dass die Rechnung sehr  weit hinten zu finden ist. Wie du sie in so einem Fall wieder findest, um das Datum richtig zu stelln, ist im nächsten Abschnitt beschrieben.
{.is-warning}


- *Finanzen \> Übersicht \> unbezahlte Rechnungen*: hier scheint die Rechnung nur dann auf, wenn kein Datum bei “bezahlt am” eingegeben wurde, unabhängig davon, ob die Rechnung auch wirklich bezahlt wurde\!

Die Details zu einer bestimmten Rechnung sind über den Link in der ersten Spalte mit der Rechnungsnummer ersichtlich ("Rechnungs-Ansicht").

## Verschollene Rechnung finden und wiederherstellen

Es gibt folgende Möglichkeiten, eine bereits angelegte Rechnung wieder zu finden, die in der Liste der Rechnungen nicht dort aufscheint, wo sie sein sollte: 

1. Gehe auf die letzte Seite der Rechnungsliste mit der Schaltfläche `>>`, wo du sie dann finden solltest, wenn in der Rechnung kein Datum eingegeben wurde, oder ein falsches Datum, dessen Jahreszahl vor der ersten korrekt angelegten Rechnung liegt.
1. Gehe auf *Finanzen \> Übersicht \> unbezahlte Rechnungen*, wo du die Rechnung findest, wenn sie noch nicht bezahlt wurde (d.h. wenn noch kein Datum bei *bezahlt am* eingegeben wurde). Manchmal passiert es, dass das Rechnungsdatum versehentlich unter "bezahlt am" eingegeben wird, und statt dem "bezahlt am" Datum das Rechnungsdatum freigelassen wird. Dann erscheint die Rechnung auch nicht unter den unbezahlten, obwohl sie noch gar nicht bezahlt wurde. 
1. Wenn die Rechnung bereits mit einer Bestellung verknüpft wurde: gehe über *Finanzen > Bestellungen abrechnen* (Zugriffsrecht erforderlich) auf die entsprechende Bestellung und klicke hier auf *Rechnung > Rechnung bearbeiten*. 
1. [Exportiere die Liste der Rechnungen über die Schaltfläche *CSV* in eine Datei](/de/documentation/admin/lists), und suche in dieser Datei nach der Rechnung. Dabei kannst du z.B. in einem Tabellenprogramm wie unter dem Link beschrieben einen Filter verwenden, um nur die Rechnungen einer Lieferantin anzeigen zu lassen.

> Wenn du die Rechnung gefunden hast, gib bitte das richtige Datum ein und beachte wie oben unter *Rechnung anlegen* beschrieben, dass das Datumsformat richtig ist.
{.is-info}

## Rechnung bearbeiten

Um eine bereits angelegte Rechnung zu bearbeiten: zunächst wie oben beschrieben anzeigen und dann “bearbeiten” auswählen. Zusätzlich gibt es noch die Möglichkeit über *Finanzen \> Bestellungen abrechnen \> Bestellung auswählen \> Rechnung bearbeiten*.

> Benutzerinnen ohne Berechtigung *Finanzen* können nur Rechnungen bearbeiten, die sie selbst angelegt haben, und die noch nicht bezahlt sind.
{.is-warning}


> Wenn bereits ein Anhang hochgeladen wurde, ist dieser in der *Bearbeiten*-Ansicht nicht sichtbar, sondern nur in der Anzeige-Ansicht (siehe oben). Wenn du den Anhang unverändert lassen möchtest, brauchst du hier den Anhang nicht nochmal hochladen. Nur wenn du den bereits hochgeladenen Anhang durch einen anderen ersetzen möchtest, wähle hier den neuen Anhang aus.
{.is-warning}



# Rechnung prüfen



## Rechnung Detailansicht
In der Rechnungsdetailansicht unmittelbar nach dem Erstellen der Rechnungs oder über *Finanzen > Rechnungen > Nummer oder Rechnungsdatum anklicken* sind folgende Details einzusehen:
- **Pfandbereinigter Betrag** = Rechnungsbetrag - Pfand berechnet + Pfand gutgeschrieben
- **Total** = Summe aus Bestellungen und Lager-Lieferungen Brutto (inkl. Pfand und Mwst, d.h. nicht Pfand-bereinigt\!), neu seit 2021-01: inklusive Transportkosten (werden bei Bestellung als zusätzlicher Plus-Betrag angezeigt; Transportkosten anlegen: siehe [Bestellungen](/de/documentation/admin/orders), Beispiel für Darstellung siehe unten).




> **Pfandbereinigter Betrag** und **Total** sollten übereinstimmen. 
{.is-warning}

Falls nicht, bedeutet das:
- **Pfandbereinigter Betrag **größer als** Total**: Lieferantin verrechnet mehr, als den Foodcoop Mitgliedern vom Guthaben abgezogen wird. Die Foodcoop macht Verlust.
- **Pfandbereinigter Betrag **kleiner als** Total**: Lieferantin verrechnet weniger, als den Foodcoop Mitgliedern vom Guthaben abgezogen wird. Die Foodcoop macht “Gewinn”.

> Lager-Lieferungen werden bei **Total** korrekt berücksichtigt, was in älteren Foodsoft-Versionen nicht der Fall war.
{.is-info}

> Wenn die Bestellung(en) [Lager](/de/documentation/admin/storage)-Bestellungen enthalten, werden diese auch zu **Total** dazugerechnet. Wenn für diese Artikel dann eine entsprechende Lager-Lieferung angelegt und in der Rechnung eingetragen wird, werden die Lager-Artikel bei **Total** doppelt dazugezählt. Mit diesem Änderungsvorschlag für die Foodsoft sollte das behoben sein: https://github.com/foodcoops/foodsoft/pull/1075 bzw. https://github.com/foodcoopsat/foodsoft/pull/5
> {.is-danger}

## Unbezahlte Rechnungen
Die Seite *unbezahlte Rechnungen* kann über *Finanzen > Übersicht* oder *Finanzen > Rechnungen* aufgerufen werden. Es werden nach Produzentinnen gruppiert alle unbezahlten Rechnungen (keine Datum bei *bezahlt am* eingetragen) aufgelistet:

![admin_finances_order_transportkosten_unbezahlte_rechnungen.png](/uploads-de/admin_finances_order_transportkosten_unbezahlte_rechnungen.png) 

* Rechnungsdatum, Rechnungsnummer, Rechnungsbetrag, Foodcoop-Gewinn
* IBAN, falls für [Lieferantin](/de/documentation/admin/suppliers) hinterlegt
* Verwendungszweck: Rechnungsnummer oder mit Beistrichen getrennte Liste der Rechnugsnummern, falls mehrere unbezahlte Rechnungen für die selbe Lieferantin aufgelistet wurden
* Gesamtsumme: Rechnungsbetrag oder Summe der Rechnungsbeträge, falls mehrere unbezahlte Rechnungen für die selbe Lieferantin aufgelistet wurden. 

> **Verwendungszweck und Gesamtsumme** sind für eine gemeinsame Überweisung von mehreren Rechnungen in einer einzelnen Überweisung gedacht, siehe *Rechnungen bezahlen*. 
{.is-info}


> **Foodcoop-Gewinn** ist die Differenz zwischen Einnahmen von den Mitgliedern für ihre Bestellungen und der Ausgaben für die Rechnung. Plus-Beträge bedeuten einen Gewinn für die Foodcoop und sind grün dargstellt, Minus-Beträge einen Verlust und sind rot dargestellt. Wenn kein Differenzbetrag angezeigt wird, bedeutet das eine exakte Übereinstimmung der Beträge (Differenz ist Null).
{.is-info}


> Wenn die Bestellung(en) [Lager](/de/documentation/admin/storage)-Bestellungen enthalten, werden diese auch zu den Einnahmen von den Mitgliedern für ihre Bestellungen dazugerechnet, obwohl die Foodcoop selbst dafür aufkommen muss. Lager-Lieferungen werden (anders als in der Rechnungsansicht) nicht berücksichtigt. Mit diesem Änderungsvorschlag für die Foodsoft sollte das behoben sein: https://github.com/foodcoops/foodsoft/pull/1075 bzw. https://github.com/foodcoopsat/foodsoft/pull/5
> {.is-danger}



## Rechnungsbilanz bei *Bestellung abrechnen*

Unter *Finanzen > Bestellungen abrechnen* findest du ebenfalls eine Gegenüberstellung von Bestellung und Rechnung, die allerdings nur dann brauchbar ist, wenn es genau eine Bestellung gibt, die der Rechnung zugeordnet wird. Werden mehrere Bestellungen zugeordnet, wird immer nur die aktuelle Bestellung mit der gesamten Rechnung verglichen.

## Ursachen für Differenzen

Foodcoops sollten grundsätzlich weder Gewinn noch Verlust machen. Ab welchem Differenzbetrag eine Nachforschung Sinn macht, ist Ermessenssache der Foodcoop. Wegen ein paar Euro Differenz stundenlang auf Fehlersuche zu gehen, ist schnell mal ein unverhältnismäßig hoher Aufwand.
Zufällige, einmalige Fehler sind eher tolerierbar als systematische Fehler, die wiederholt auftreten, weil z.B. Artikelpreise in der Foodsoft falsch eingegeben sind.

Mögliche Ursachen für Differenzen sind:
- **Rundungsdifferenzen**: Durch unterschiedliche Arten der [Mehrwertsteuer-Berechnung](/de/documentation/admin/finances/value-added-tax) in Verbindung mit Rundungen kann es zu geringen Differenzen in der Größenordnung von max. 1 Cent pro Artikel kommen. Abhilfe: Artikelpreise um 1 Cent anheben, falls es regelmäßig zu Verlusten für die Foodcoop kommt.
- **Fehler in der Rechnung der Lieferantin**. Abhilfe: Rechnung prüfen und bei der Lieferantin reklamieren.
- Unterschiedlicher **Artikelpreis** in Bestellung und Rechnung. Abhilfe: Preis in der Foodsoft korrigieren, oder bei der Lieferantin reklamieren
- Unterschiedliche **Artikelmengen** in Bestellung und Rechnung. Abhilfe: in der Foodsoft [Bestellung anpassen](/de/documentation/admin/orders) an die Mengen, die geliefert wurden, oder bei der Lieferantin reklamieren. Beim Abholen oder Aufteilen der Waren kann können auch Artikel "verloren" gehen oder versehentlich an falsche Mitglieder geraten. Eine Nachforschung ist meist sehr aufwändig und nur selten erfolgreich. Auch wenn ohne Klärung wohl oder übel der Verein die Kosten für die fehlenden Artikel übernehmen muss, ist das auf jeden Fall der zeitsparendere Weg.
- **Variables Gewicht** bei Artikeln, die pro Stück bestellt werden, Lieferantin verrechnet nach tatsächlich geliefertem Gewicht. Abhilfe:  in der Foodsoft [Bestellung anpassen](/de/documentation/admin/orders) an die Mengen, die geliefert wurden, eventuell den Grundpreis von Artikeln mit variablem Gewicht in der Foodsoft erhöhen, damit er einem größeren Artikelgewicht entspricht.
- Lieferantin verrechnet **zusätzliche Kosten** wie Transportkosten oder Pfandgebinde. Abhilfe: wie beschrieben Transportkosten und Pfandkosten in der Foodsoft eingeben, damit sie in der Bilanz berücksichtigt werden.
- **Falsche Bilanzberechnung der Foodsoft** in Verbindung mit Lager-Bestellungen und Lager-Lieferungen, siehe oben bei *Rechnung prüfen* und *Unbezahlte Rechnungen*.






## Transportkosten in Rechnungen
Beispiel:
- 19,20 Euro Bestellbetrag
- 10 Euro Transportkosten 
- 30 Euro Rechnungsbetrag (inkl. Transportkosten)

> Beim Erstellen oder Bearbeiten der Rechnung beim Auswählen der Bestellung scheinen die Transportkosten zunächst nicht auf, wenn sie vorher schon [zur Bestellung hinzugefügt wurden](/de/documentation/admin/orders): 
>
> ![admin_finances_order_transportkosten_rechnung_bearbeiten.png](/uploads-de/admin_finances_order_transportkosten_rechnung_bearbeiten.png)
{.is-warning}



> Ebenbso werden Transportkosten nicht in der Ansicht einzelner Bestellungen unter *Finanzen > Bestellungen abrechnen* angezeigt: ![admin_finances_order_transportkosten_bestellung_abrechnen.png](/uploads-de/admin_finances_order_transportkosten_bestellung_abrechnen.png)
{.is-warning}



> Transportkosten werden bei der Rechnungsbilanz beim Betrag der Bestellung berücksichtigt unter *Rechnung Detailansicht*, *Unbezahlte Rechnungen* :
> ![admin_finances_order_transportkosten_rechnung.png](/uploads-de/admin_finances_order_transportkosten_rechnung.png)
> ![admin_finances_order_transportkosten_unbezahlte_rechnungen.png](/uploads-de/admin_finances_order_transportkosten_unbezahlte_rechnungen.png) 
{.is-success}

> Wenn Transportkosten angelegt, aber nicht auf die Bestellgruppen aufgeteilt werden, muss die Foodcoop dafür aufkommen. Das scheint derzeit in den Bilanzen nicht auf, es wirkt so, als ob die Bestellgruppen dafür aufkommen würden. Ebenso wenn die Transportkosten zwar auf die Bestellgruppen aufgeteilt werden, aber eine Lager-Bestellung dabei ist, muss die Foodcoop für die Transportkosten der Lagerbestellung aufkommen. Mit diesem Änderungsvorschlag für die Foodsoft sollte das korrekt berücksichtigt werden: https://github.com/foodcoops/foodsoft/pull/1075 bzw. https://github.com/foodcoopsat/foodsoft/pull/5
{.is-danger}




## Freigabe Rechnung zur Bezahlung 

> Empfehlung: ins Notizfeld “bezahlen” schreiben, falls für das Bezahlen von Rechnungen andere Personen zuständig sind. 
{.is-info}


# Rechnungen bezahlen

Für die Bezahlung von Rechnungen gibt es folgende Möglichkeiten:
- **Manuelle Überweisung per E-Banking** durch Foodcoop Mitglied mit Bankzugang. Die Daten für die Überweisung (Empfängerin, IBAN, Betrag, Verwendungszweck: Rechnungsnummer(n)) können aus der Foodsoft von der Übersicht *Finanzen > Rechnungen > unbezahlte Rechnungen* bzw. *Finanzen > Übersicht > Unbezahlte Rechnungen > alle anzeigen* kopiert werden.
- **Automatisierte Überweisung durch die Foodsoft über die Bankanbindung**: Wenn die Foodsoft mit dem Bankkonto verknüpft ist, macht die Foodsoft das automatisch, siehe [Bankkonto](/de/documentation/admin/finances/bank-accounts).
- **Per Einzieher**: manche Lieferantinnen ziehen die Rechnungsbeträge selbst vom Foodcoop Bankkonto ab.

Sobald eine Rechnung bezahlt ist, sollte sich auch in der Foodsoft als bezahlt gekennzeichnet werden, indem  bei *bezahlt am* das Datum der Bezahlung eingetragen wird, wenn sie tatsächlich bezahlt wurden (z.B. indem im Ebanking eine Überweisung durchgeführt wurde). Wenn die Foodsoft [mit dem Bankkonto verknüpft ist](/de/documentation/admin/finances/bank-accounts), geschieht dies automatisch beim nächsten Import der Bankdaten.

> Bezahlte Rechnungen scheinen nicht mehr unter *Finanzen > Rechnungen > unbezahlte Rechnungen* und *Finanzen > Übersicht > unbezahlte Rechnungen* auf.
{.is-success}


# Rechnungen exportieren

*Finanzen > Rechnungen: [CSV](/de/documentation/admin/lists)*

Es werden für alle bisher angelegten Rechnungen (neueste zuerst) folgende Daten in einer Zeile je Rechnung exportiert:

| Erstellt am|Erstellt von|Rechnungs-datum|Lieferant|Nummer|Betrag|Total|Pfand berechnet|Pfand gutge-schrieben|Bezahlt am|Notiz |
| -----|-----|-----|-----|-----|-----|-----|-----|-----|-----|----- |
| 2021-11-19 15:48:00 +0100|Stefan |44517|Ackerlhof|21551|74,01|103,2|0|0||Rosa und grüne Liste beachten |
| 2021-11-16 16:38:22 +0100|Mirko |44516|SOS-Parmesan|SOS-20212460|520|520|0|0|44516|bitte bezahlen |
| 2021-11-17 15:37:02 +0100|Ina |44515|Mauracher|178380|82,39|82,67|0|0||Bitte bezahlen, ist geprüft! Danke :-) |

> Falls die Tabelle rechts abgeschnitten ist, kannst du den Zoom-Faktor in deinem Browser verkleinern, oft geht das mit Strg-Minus (Ctrl-Minus).
{.is-info}


