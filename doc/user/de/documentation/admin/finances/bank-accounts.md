---
title: Bankkonto mit Foodsoft verknüpfen
description: Automatisierte Erfassung von neuen und bestehenden Überweisungen
published: true
date: 2024-01-26T22:11:10.178Z
tags: 
editor: markdown
dateCreated: 2021-04-20T23:17:42.160Z
---

# Einleitung

## Was ermöglicht die Bankanbindung?

Die Foodcoop bietet die Option einer Bankanbindung. Wenn eingerichtet, ermöglicht dies der Foodsoft, die Bankkontozeilen der Vereinskonten zu importieren, und  Übweisungen von Rechnungen zu tätigen (in Arbeit) und in Folge als bezahlt zu markieren. 

Dies bietet folgende Vorteile:
- **Überweisungen der Mitglieder** auf das Vereinskonto können von der Foodsoft automatisiert durch die Verwendung von Zahlunsgreferenzcodes automatisch erkannt und den Bestellgruppen zugeordnet werden. So entfällt der manuelle Prozess, z.B. Bestellguthaben oder Mitgliedsbeitrag den Bestellgruppen in der Foodsoft gut zu geschreiben. 
- **Überweisungen von Rechnungen** an die Lieferantinnen können von der Foodsoft erkannt, zugeornet und als bezahlt markiert werden.  
- Es werden interne Querverweise, genannt **Finanzlinks**, (teilweise) automatisch erstellt. Dies ermöglicht es, Buchungen zu verknüpfen, um diese jederzeit nachvollziehbar zu gestalten. Werden alle Banktransaktionen, Kontotransaktionen und Rechnungen mit einem Finanzlink verknüpft, lässt sich eine nachvollziehbare (einfache) doppelte Buchhaltung umsetzten.
    - Dies spart eine externe Buchungssoftware bzw. redudantes Mitschreiben.
    - In Verknüpfung mit Trennung in Kontotransaktionstypen wie etwa Treuhand und Verein ermöglicht dies eine saubere Buchhaltung mit nur einem Vereinskonto
- Es werden auch **mehrere Vereinskonten** unterstützt. 

> Dass die Foodsoft Überweisungen am Bankkonto durchführen kann, um Rechnungen zu bezahlen, wird gerade entwickelt und befindet sich in der Testphase (Stand  16.02.2021). 
{.is-danger}


## Unterstützte Banken (Österreich)

Die Bankkontozeilen werden je nach Bank und Unterstütztung der Bankanbindung händisch/halbautomatisch oder automatisiert importiert. 

> Da sich noch kein einheitlicher Standard für die Kommunikation mit E-Banking-Systemen durchgesetzt hat, und die Kommunikation bis auf wenige Ausnahmen nicht dokumentiert bzw. öffentlich ist, muss die Bankanbindung für jede Bank angepasst werden. Dies erfolgt daher meist durch "Abhorchen" der Kommunikation zwischen Webbrowser und E-Banking-Server und erfordert einiges an Spezialwissen. 
{.is-info}


Für folgende Banken unterstützt die Foodsoft eine Bankanbindung:


### Vollautomatisch

- Erste Bank
> Synchronisation zwei mal täglich um ca. 08:00 und 20:00 Uhr (Sommerzeit) bzw. 07:00 und 19:00 Uhr (Winterzeit)
{.is-info}

> Bankverbindung muss alle 90 Tage neu hergestellt werden (*Finanzen > Bankkonten > Importieren*, per PushTAN bestätigen)
{.is-warning}

> [Anleitung zur erstmaligen Einrichtung der ErsteConnect Bankanbindung](https://forum.foodcoops.at/t/foodsoft-ersteconnect-bankanbindung-einrichten/5965)
{.is-info}

### Halbautomatisch

- Raiffeisen, Umweltcenter Gunskirchen
- Holvi
- Oberbank
- Sparda
- Bawag, Easybank (neu seit 2021-12)

> Auslösen durch Mitglied mit Finanzzugriff via  *Finanzen > Bankkonten > Importieren*. Zweifaktorauthentifizierung erforderlich.
{.is-info}

> Falls die Bank deiner Foodcoop hier nicht vorkommt, wende dich bitte im Forum an @paroga. Bitte diese Liste ergänzen, falls eine  neue Bank hinzugefügt wurde.
{.is-warning}

### Nicht unterstützte Banken

Banken, die von FC verwendet werden, wo es noch keine Anbinung gibt:
- *Bank Austria (prESSBAUM)*



## Finanzlinks

Bankkontobuchungen können verknüpft werden mit
- [Foodsoft Kontotransaktionen](/de/documentation/admin/finances/accounts)
- [Rechnungen](/de/documentation/admin/finances/invoices)
- anderen Bankkontobuchungen

Diese Links werden großteils automatisch von der Foodsoft erstellt, in Einzelfällen kann es sinnvoll/notwendig sein, sie händisch zu erstellen bzw. zu bearbeiten.

## Zahlungsreferenzcodes

Wenn bei Banküberweisungen im Feld *Zahlungsreferenz* oder *Verwendungszweck* ein Zahlungsreferenzcode angegeben wird, kann die Foodsoft nach dem Importieren der Bankkonto Buchungszeilen die Zahlungseingänge automatisch den Mitglieder Konten zuordnen und entsprechende Transaktionen anlegen.

> Die Verwendung von Zahlungsreferenzcodes erspart eurer Foodcoop viel Arbeit!
{.is-success}


Jedes Mitglied findet seinen Zahlungsreferenz-Rechner im [Dropdownmenü des Profilnamens](/de/documentation/usage/profile-ordergroup). 

> Der Menüpunkt *Zahlungsreferenz-Rechner* wird erst angezeigt, sobald  bei [*Kontotransaktion Klassen und Typen*](/de/documentation/admin/finances/accounts) mit zumindest einem Kürzel eines Transaktionstyps angelegt wurden, mindestens ein Bankkonto hinzugefügt wurde, und du danach aus der Foodsoft aussteigst und wieder neu einloggst.
{.is-info}

Weitere Infos zum Zahlunsgreferenzcode:
- [Zahlungsreferenz-Rechner](/de/documentation/usage/profile-ordergroup#zahlungsreferenz-rechner) Wie Mitglieder ihre Zahlunsgreferenzcodes erstellen können, Beispiele, häufige Fehler
- [Transaktionsklassen](/de/documentation/admin/finances/accounts) Was eingerichtet werden muss, damit Zahlunsgreferenzcodes verwendet werden können
{.links-list}

# Bankkonto einrichten in der Foodsoft


Das Einrichten eines Bankkontos in der Foodsoft erfordert die Schritte
1. Bankproxy anlegen
1. Bankgateway anlegen
1. Bankkonto anlegen

Diese Schritte müssen für jedes Bankkonto durchgeführt werden, wie im Folgenden beschrieben.

> Es können auch mehrere Bankkonten eingerichtet werden.
{.is-info}


## Bankproxy anlegen

1. https://bankproxy.foodcoops.at/admin öffnen
1. *Authorize* klicken
1. Unter *Create* einen Namen vergeben (z.B. Foodcoop XY ELBA) und den Typ auswählen. Für *Raiffeisen MeinELBA* muss *at.raiffeisen.elba* ausgewählt werden.
1. Abhängig vom gewählten Typ müssen dann die zusätzlichen Eingabefelder befüllt werden. Die einzelnen Felder sind unter https://bankproxy.github.io/connectors/ dokumentiert.
1. Nach dem Klicken von *Create* werden die Credentials angezeigt. Den Teil neben *Authorization:* beginnend mit *Basic*, gefolgt von einem Leerzeichen und einer Zeichenkette aus Buchstaben, Zahlen und mit einem = am Ende (blau markierter Bereich im Bild), wird in der Foodsoft benötigt und kann gleich in die Zwischenablage kopiert werden.

![admin_finances_bankproxy-admin.png](/uploads-de/admin_finances_bankproxy-admin.png)



## Bankgateway anlegen
In der Foodsoft unter *Admin > Finanzen* muss jetzt ein neuer BankGateway angelegt werden. 
- Es muss ein beliebiger *Name* (z.B. ELBA) gewählt werden. 
- Als *URL* wird https://bankproxy.foodcoops.at und  
- unter *Authorization-Header* den kopierten Text in der Zwischenablage aus dem vorherigen Schritt einfügen. 
- Falls ein automatische Import möglich ist (geht derzeit nur mit *Erste Connect*) kann unter *Bedienerlos-Benutzerin* noch jene Benutzerin eingetragen werden, die den Zugang konfiguriert. Ansonsten kann das Feld auch leer gelassen werden.





## Bankkonto anlegen

Um ein Bankkonto anzulegen ist eine Berechtigung als Administrator erforderlich. Unter *Administration > Finanzen > Neues Bankkonto anlegen* wählen. Ein Dialogfenster öffnet sich mit den selbsterklärenden Feldern 
- Name\*, 
- IBAN\*, 
- Beschreibung 
- Kontostand: hier einmalig den aktuellen Kontostand des Bankkontos eingeben. Dieser wird benötigt, um aus den zukünftigen Transaktionen den aktuellen Kontostand in der Foodsoft anzeigen zu können
- Bankgateway: den zuvor angelegten Bankgateway auswählen.

Mit *Bank account erstellen* wird das Bankkonto in der Foodsoft angelegt. 

> Die E-Banking Zugangsdaten fürs Bankkonto musst du erst beim Importieren der Bankdaten angeben, siehe unten.
{.is-info}


> Falls noch nicht geschehen, sollten noch [Transaktionsklassen und -typen](/de/documentation/admin/finances/accounts) eingerichtet werden, um Zahlungsreferencodes verwenden zu können.
{.is-info}

## Spezialfälle

### Erste Bank
Falls eure FoodCoop ein Konto bei der ErsteBank hat, gibt es die Möglichkeit, dass die Banktransaktionen von der Foodsoft automatisch im Hintergrund importiert werden können. Das manuelle Importieren mit der Freigabe über die s Identity-App entfällt dadurch.


Für die Verwendung von ErsteConnect ist ein gültiges Zertifikat notwendig, das regelmäßig erneuert werden muss. Die Erste hat dazu ein Kooperation mit I.CA, welche die Zertifikate ausstellen.

Detaillierte Anleitung dazu siehe https://forum.foodcoops.at/t/foodsoft-ersteconnect-bankanbindung-einrichten/5965

### Andere Foodsoft-Instanz verknüpfen (z.B. IG FoodCoops)

Es ist auch möglich, eine Dummy-Bankanbindung anzulegen, um eine andere Foodsoft-Instanz zu verknüpfen.

> Für die Verknüpfung mit der IG FoodCoops Foodsoft (https://app.foodcoops.at/austria) gibt es im Vernetzungsforum eine genaue Anleitung:
https://forum.foodcoops.at/t/finanz-anbindung-eure-foodsoft-ig-foodcoops-foodsoft-austria/8009
{.is-success}

Anleitung für andere Fälle:

#### 1. OAuth Daten der zu verknüpfenden Foodsoft aufrufen

> Hierfür braucht ihr Admin-Rechte für die Foodsoft, die ihr verknüpfen wollt.
{.is-warning}

In der Foodsoft, die ihr verknüpfen wollt, auf Administration -> Einstellungen -> Apps (rechts oben) klicken. Neue Applikation anlegen* oder ggf. bestehende Foodsoft aufrufen (auf den Namen klicken). Ihr braucht **Applikations-ID** & **Secret** für den nächsten Schritt.

*Beispieldaten für neue Applikation:
Name: `Foodsoft`
Redirect URI: 
`https://app.foodcoops.at/`
`https://bankproxy.foodcoops.at/callback`
Confidential: false (kein Häkchen)
Scopes: frei lassen

#### 2. Bankproxy konfigurieren

Öffnet die Bankproxy-Admin-Oberfläche unter https://bankproxy.foodcoops.at/admin und klickt auf `Authorize`.
Unter Create gebt einen beliebigen Namen ein und wählt bei Type `net.foodcoops.foodsoft` aus. Daraufhin erscheinen zusätzliche Felder, die wie folgt auszufüllen sind:
    IBAN: Ein Dummy-IBAN, z.B. ZZ75FOODSOFT
    InstanceURL: z.B. `https://app.foodcoops.at/austria`
    OAuthClientId: Applikations-ID aus obigem Schritt
    OAuthClientSecret: Secret aus obigem Schritt
    
Nach einem Klick auf Create erscheinen darunter die Bankproxy-Credentials. Kopiert den Text neben Authorization, da in der Foodsoft benötigt wird.

#### 3. Bank Gateway in eurer Foodsoft anlegen

Ruft eure Foodsoft auf und klickt auf Administration → Finanzen.
Dort rechts oben auf *Neuen Bank Gateway* anlegen und folgende Daten eingeben:
Name: z.B. IG FoodCoops
URL: z.B. `https://bankproxy.foodcoops.at`
Authorization-Header: Der obig kopierte Text, beginnend (inklusive) mit Basic
Bedienerlos-Benutzer_in: Die Person, die später auf „Importieren“ klickt (üblicherweise du selbst).

#### 4. Dummy-Bankkonto in eurer Foodsoft anlegen

Ebenso unter Administration → Finanzen:
Klick rechts oben auf *Neues Bankkonto anlegen*.
Name: z.B. IG FoodCoops Guthaben/Mitgliedsbeitrag
IBAN: ZZ75FOODSOFT (oder ähnlich, Dummy)
Bankgateway: Wähle den eben angelegten Gateway aus.

#### 5. Transaktionen und Kontostand importieren

Unter Finanzen → Bankkonten solltest du nun mehrere Bankkonten sehen, falls ihr auch euer eigenes Bankkonto an die Foodsoft angebunden habt. Wähle das neue aus und klicke rechts oben auf Importieren. Bestätige mit *Get Access*, nun sollten die Transaktionen und der Kontostand importiert werden.

> Sollte es in der verknüpften Foodsoft mehrere Kontotransaktionsklassen (z.B. Bestellguthaben und Mitgliedsbeitrag-Guthaben) geben, wird der "Kontostand" dieser Kontotransaktionsklassen beim Import summiert - auch wenn der Mitgliedsbeitrag eigentlich nicht zum Guthaben zählen sollte.
{.is-warning}

> Vermutlich läuft der Import nicht täglich vollautomatisch ab (wie bei ErsteConnect), sondern ihr müsst manuell auf Importieren klicken.
{.is-info}

#### 6. Nutzen

Nun könnt ihr z.B. die ausgehenden Mitgliedsbeitrag-Überweisungen von eurem Bankkonto mit dem jeweiligen Eingang auf eurem IG-Kontostand verknüpfen, ebenso bei Guthaben-Überweisungen.

Außerdem scheint euer IG-Guthaben nun im Finanzbericht auf, den ihr unter Finanzen → Übersicht → Bericht erstellen (rechts oben) generieren könnt.

# Bankkontozeilen importieren und weiterverarbeiten

## Import

Das Importieren der Kontozeilen erfolgt bei den meisten Bankanbindungen nicht automatisch und muss jedesmal nach Eingang neuer Banktransaktionen in der Foodsoft durchgeführt werden. Es werden dabei nur die jeweils neu hinzugekommenen Buchungszeilen importiert.

1.  *Finanzen \> Bankkonten \> Importieren*: Ebanking Zugangsdaten bei Disposer-Nr. und PIN eingeben;  Mit der Option „Remember“ merkt sich der Browser deine Zugangsdaten, und du brauchst sie beim nächsten Mal nicht mehr einzugeben.
2.  Es sollte in deiner Bank-App am Smartphone eine Anfrage für eine Freigabe mit einem 4-stelligen Buchstaben/Zahlencode erscheinen, der auch in der Foodsoft angezeigt wird. Diese Freigabe bitte im Bank-App erteilen durch Eingabe deines Codes, Fingerabdrucks oder ähnlichem.
3.  Neue Kontozeilen werden in die Foodsoft importiert, die Anzahl der Transaktionen wird angezeigt. Die Buchungszeilen werden zunächst noch nicht bearbeitet, es finden während des Imports keine Foodsoft-Transaktionen für Mitglieder statt, es werden keine Rechnungen als bezahlt markiert, und noch keine Finanzlinks erstellt, erkennbar an den grünen Schaltflächen in der Spalte Finanzlink *Hinzufügen*.
4.  *Finanzen > Bankkonten > Transaktionen zuordnen*: durch diese Funktion werden Foodsoft Transaktionen auf Basis der Zahlungsreferenzcodes in den Überweisungen durchgeführt, Rechnungen als bezahlt markiert und die neu importierten Kontozeilen mit Finanzlinks den enstprechenden Transaktionen und Rechnungen zugeordnet, wie im Folgenden beschrieben. 


## Transaktionen zuordnen

Die Funktion *Finanzen \> Bankkonten \> Transaktionen zuordnen* erledigt folgende Aufgaben:

- Automatische Erstellung von Finanzlinks
- Guthaben aufladen
- Rechnungen als bezahlt kennzeichnen


In folgenden Fällen wird mit der Funktion „Transaktionen zuordnen“ ein Finanzlink für Kontonbuchungen erstellt: 
- Buchung enthält **Zahlungsreferenzcode**: es wird eine entsprechende Foodsoft Kontotransktion durchgeführt, indem der entsprechenden Bestellgruppe der Betrag / die Beträge gutgeschrieben werden
- Buchung kann einer Rechnung zugeordnet werden: die **Rechnung wird als bezahlt markiert**, siehe unten. 

Falls eine Buchung nicht erkannt wird (z.B. weil Zahlungsreferenzcode fehlerhaft oder Rechnungsdaten  nicht übereinstimmen), erfolgt keine Aktion, die grüne Schaltfläche *Hinzufügen* unter Finanzlinks bleibt erhalten. In diesem Fall sollte manuell ein Finanzlink erstellt werden, siehe unten. 

> Zahlunsgreferenzcodes können *nicht* für Rücküberweisungen verwendet werden. Wenn z.B. einem Mitglied versehentlich überwiesene 10 Euro Mitgliedsbeitrag zurücküberwiesen werden sollen, und dabei als Zahlungsreferenz `FS123.456M-10` verwendet wird (das Mitglied hat zuvor mit dem Code `FS123.456M10` überwiesen), so wird diese Transaktion leider **nicht** zugeordnet und dem Mitglied werden keine 10 Euro Guthaben abgezogen. Es geht aber recht rasch, diese Zuordnung wie unten beschrieben manuell durchzuführen.  
{.is-warning}


## Foodsoft Rechnungen

Automatisch mit *Finanzen > Bankkonten > Import > Transaktionen* zuordnen:
- Banktransaktion wird über Finanzlink mit [Rechnung](/de/documentation/admin/finances/invoices) verknüpft.
- Rechnung wird als bezahlt mit entsprechendem Datum markiert und verschwindet damit aus der Liste *Finanzen > Übersicht > unbezahlte Rechnungen*.

### Kriterien für die Zuordnung

Was wird genau überprüft und muss ident sein, damit die Überweisung einer Foodsoft-Rechnung zugeordnet wird:

1.  Anhand der **IBAN** der LieferantIn werden offenen Rechnungen gesucht. Die IBAN muss in der Foodsoft unter [*Artikel > Lieferanten*](/de/documentation/admin/suppliers) bei der jeweiligen Lieferantin unter *Bearbeiten* im Feld *IBAN* eingegeben sein.
2.  Für jede **Rechnungsnummer** der [Rechnung](/de/documentation/admin/finances/invoices) wird geprüft, ob diese im Verwendungszweck vorkommt.
3.  Die Summe der anhand der Rechnungsnummern "passenden" Rechnungen aus Schritt 2 muss mit dem **Überweisungsbetrag** übereinstimmen.

Wenn alle drei Kriterien zutreffen, wird ein Finanzlink angelegt und die Rechnung(en) als bezahlt markiert.


> **Leerzeichen** in der Rechnungsnummer sollten kein Problem sein, z.B. Rechnungsnummer in der Foodsoft "2020-1 bis 3", Überweisung mit Zahlungsreferenz "Rechnungen 2020-1 bis 3" ok.
{.is-info}


> Bei **mehreren unbezahlten Rechnungen desselben Produzenten** wird eine Summe der Rechnungen angezeigt. Diese Summe kann mit einer einzigen Überweisung bezahlt werden, die einzelnen Rechnungsnummern sind beim Verwendungszweck alle anzugeben. Die Rechnungen werden als bezahlt markiert und alle der Sammelüberweisung zugeordnet. 
{.is-info}


### Beispiele zur automatischen Erkennung von Rechnungsnummern

Angenommen, es gibt Rechnungen mit folgenden Rechnungsnummern:

+ a. "1"
+ b. "3"
+ c. "2020-10"
+ d. "#789"

Die folgende Verwendungszwecke würden jeweils folgende Rechnungen zugeordnet:

- "1"         (a)
- "Rechnung 1" (a)
- "Re-Nr. \#1" (a)
- "Irgendwas 123" (a) und (b)
- "ReNr: 1, 3" (a) und (b)
- "Nr 333"    (b)
- "2020-10"   (a) und (c)
- "#789"      (d)
- "789"       nichts


### Manuelle Zuordnung von Rechnungen

Falls die automatische Zuordnung nicht erfolgreich war, weil eines oder mehreres der oben angeführten Kriterien nicht erfüllt war, sollten ersatzweise folgende Schritte zur manuellen Zuordnung durchgeführt werden:

1.  *Finanzen \> Bankkonten \> Buchungszeile für Rechnung \> Finanzlink hinzufügen \> Rechnung(en) hinzufügen* \> entsprechende Rechnung in der Liste auswählen (eventuel Fenster vergrößern oder mit F11 auf Vollbild schalten um „Speichern“ Schaltfläche anzuzeigen); Schritt mehrmals ausführen wenn mehrere Rechnungen zu verknüpfen sind
2.  *Finanzlink anzeigen \> Rechnung auswählen \> Bearbeiten bezahlt am*: aktuelles Datum  eingeben
3.  *Finanzen \> Überblick \> unbezahlte Rechnungen*: prüfen, ob die manuell als bezahlt gekennzeichnete Rechnung dort nicht mehr aufscheint 

## Finanzlinks manuell erstellen oder bearbeiten 

Wenn in einer Buchung kein oder ein [fehlerhafter Zahlungsreferenzcode](/de/documentation/usage/profile-ordergroup) (z.B. Tippfehler, ungültige Modifizierung des Codes durch Mitglied, Überweisung mittels Papier-Zahlschein, neues Mitglied noch ohne Foodsoft-Login, ...) vorhanden ist, muss manuell ein Finanzlink erstellt und eine Foodsoft-Kontotransaktion (Aufbuchen des Guthabens auf das entsprechende Foodsoft-Bestellgruppenkonto) erstellt werden. 

Ebenso kann bei Rechnungen z.B. durch abweichende Rechnungsbeträge, abweichende IBAN oder abweichende Zahlungsreferenz die Zuordnung fehlschlagen, sodass ein Finanzlink manuell erstellt und die Rechnung manuell als bezahlt markiert werden muss. 

Außerdem kann ein bestehender Finanzlink auch erweitert werden, um einer Rechnung mehrere Banktransaktionen zuzuordnen wie z.B. 
- falls die Zahlung einer Rechnung in mehreren Überweisungen erfolgte
- falls von der Lieferantin im Nachhein eine Gutschrift überweisen wurde 

Folgend Funktionen stehen unter *Finanzen > Bankkonten* in der Spalte *Finanzlink* über die Schaltfläche *Hinzufügen* (oder falls schon ein Link erstellt wurde, über den Link *Anzeigen*) zur Verfügung:

![admin_finances_bank-accounts_neue-kontotransaktion0.png](/uploads-de/admin_finances_bank-accounts_neue-kontotransaktion0.png)

### Banktransaktion hinzufügen

Eine weitere Bankkontobuchung verknüpfen, z.B. wenn eine Rechnung in mehreren Teilbeträgen bezahlt wurde. 

### Kontotransaktion hinzufügen

Aus der Liste der Kontransaktionen eine auswählen. Der Aufbau der Liste kann etwas länger dauern, wenn es in der Foodcoop schon viele Transaktionen gibt. 

### Kontotransaktion neu anlegen mit Finanzlink

*Neu Kontotransaktion hinzufügen* (Unterfunktion von *Kontotransaktion hinzufügen*): es wird eine Foodsoft-Kontotransaktion und der Finanzlink dazu erstellt. Das geht wesentlich komfortabler, als zuerst eine Kontotransaktion zu erstellen, und sie dann im Finanzlink hinzuzufügen. Anwendung z.B. wenn eine Banküberweisung für Guthaben ohne oder mit fehlerhaftem Zahlungsreferenzcode vorliegt.

![hadmin_finances_bank-accounts_neue-kontotransaktion1.png](/uploads-de/admin_finances_bank-accounts_neue-kontotransaktion1.png)

![hadmin_finances_bank-accounts_neue-kontotransaktion2.png](/uploads-de/admin_finances_bank-accounts_neue-kontotransaktion2.png)

 Die Bestellgruppe wird wenn möglich aus dem IBAN vorausgewählt, falls es bereits vorher schonmal eine Zuordnung gab. Es können auch mehrere Transaktionen hintereinander z.B. für verschiedene Transaktionsklassen für Guthaben Bestellungen/Mitgliedsbeitrag erstellt werden, bei jeder weiteren Transaktion erscheint automatisch der noch nicht verbuchte Rest des Überweisungsbetrags.


### Rechnung hinzufügen

Aus der Liste der Rechnungen auswählen. 


## Sonstige Bankkonto-Transaktionen

Zusätzlich zu den bisher genannten Bankkonto-Transaktionen gibt es noch welche, die weder unter Guthaben Aufladen noch Produzentinnen Rechnungen fallen, zum Beispiel:

- Bankspesen
- Lagerraum: Miete, Strom, Heizung, Internet, Versicherung, …
- Anschaffungen: Inventar, Vebrauchsmaterial wie Glühbirne usw.
- …

Oft handelt es sich hier um Einzieher, das heißt es werden monatlich, quartalsweise oder jährlich fixe Beträge vom Bankkonto der Foodcoop eingezogen. Um für eine korrekte Buchhaltung diesen Buchungen über Finanzlinks auch Rechnungen zuordnen zu können, ist es sinnvoll, für diese Transaktionen auch eigene Lieferantinnen und Rechnungen anzulegen, z.B:

- Wohnungsgenossenschaft: Einzug der monatlichen Miete des Lagerraums
- Stromlieferantin für Lagerraum: monatlicher Einzug der Vorschreibung
- Bank für quartalsweisen Abzug der Kontoführungsgebühren
- Sonstiges für nicht regelmäßge Aufgaben 

### Beispiel

Die Wohungsgenossenschaft, die den Lagerraum vermietet, bucht monatlich 200 Euro Miete vom Bankkonto der Foodcoop ab. 

1. In der Foodsoft wird eine **Lieferantin** „Wohnungsgenossenschaft“ angelegt der Kategorie „Betriebskosten“.
2. Nach Ablauf eines Jahres erstellt die FC in der Foodsoft eine (fiktive) Jahres-**Rechnung** für die Lieferantin „Wohnungsgenossenschaft“ über 12 x 200 = 2.400 Euro mit Rechnungsdatum = bezahlt-am-Datum = Enddatum des Rechnungszeitraums sowie einer Rechnungsbetreff z.B. für den Zeitraum: `Oktober 2019 bis September 2020`. Noch besser wäre es, die Jahresabrechnung und deren Zeitraum zu verwenden. 
3.  Unter *Finanzen \> Bankkonten* bei einer der 12 Abbuchungen (noch ohne Finanzlink) „hinzufügen“, Rechnung hinzufügen, die soeben erstellte Rechnung auswählen, dann 
4.  mit *Banktransaktion hinzufügen* die restlichen 11 Abbuchungen ebenfalls dem selben **Finanzlink zuweisen**. 
