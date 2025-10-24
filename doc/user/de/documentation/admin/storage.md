---
title: Lager
description: Verwalten des Foodcoop-Lagers und Produktinventars
published: true
date: 2025-08-14T22:47:05.083Z
tags: 
editor: markdown
dateCreated: 2021-04-20T21:55:48.199Z
---

# Lager Funktionsweise

Das Lager dient für die Verwaltung von Artikeln, die von der Foodcoop auf Vorrat beschafft und im Lagerraum der Foodcoop gelagert werden. Für das Lager können so wie die Bestellungen bei den Lieferantinnen eigene Lagerbestellungen angelegt werden, wo Bestellgruppen der Foodcoop Artikel bestellen können.  Die Foodsoft verwaltet den Lagerstand dieser Artikel und reduziert ihn bei Bestellungen entsprechend. Wenn der Lagerstand eines Artikels erschöpft ist, ist auch keine Bestellung dieses Artikels mehr möglich. Lagerartikel können entweder einfach direkt beim Hersteller ohne die Foodsoft bestellt werden, oder im Zuge einer normalen Foodsoft-Bestellung zusätzlich zu den Bestellungen der Mitglieder (auch diese Bestellung heißt in der Foodsoft „Lagerbestellung“).

> **Lagerbestellung** steht in der Foodsoft für 2 verschiedene Arten von Bestellungen:
> - um das Lager mit Artikel der Lieferantin aufzufüllen, und 
> - damit Mitglieder Artikel aus dem Lager bestellen und entnehmen können.
>
> .
{.is-info}

Das Lager hat eine eigene Artikelliste, wo die Artikel von Lieferantinnen eingebracht werden können, oder auch unabhängig von Artikeln der Lieferantinnen Lagerartikel angelegt werden können. 

Auch für Lagerartikel braucht es immer eine Lieferantin in der Foodsoft. Eine Lieferantin kann jedoch sowohl Lagerartikel als auch Artikel für Direktbestellungen der Mitglieder haben. Beispeilsweise können bei einer Bestellung zusätzliche Artikel, die nötig sind, um volle Gebinde zu erreichen, ins Lager übernommen werden: 
> Beispiel: Gebindegröße 6 Stück, 10 Stück von Mitgliedern bestellt, 2 x 6 = 12 müssen bei der Lieferantin bestellt werden,  10 davon gehen direkt an die Mitglieder, 2 ins Lager.

Über die Funktion „Lieferung“ können 
- Lagerartikel neu angelegt oder aus der Artikellliste der Lieferantin übernommen werden (nur einmalig oder bei Änderungen erforderlich), und
- Lagerartikel in den Lagerbestand der Foodsoft aufgenommen werden, indem angegeben wird, wieviel Stück von welchem Artikel ins Lager eingebracht werden.


Über Lagerbestellungen können Lagerartikel von den Mitgliedern entnommen werden. Der Lagerstand verringert sich dann entsprechend, solange die Lagerbestellung offen ist, zunächst nur der „verfügbare Lagerstand,“ wenn die Lagerbestellung abgerechnet ist, auch der eigentliche Lagerbestand. 

> Wichtig ist, dass Mitglieder nur Lagerartikel aus dem Foodcoop Lager entnehmen sollten, die sie auch vorher bestellt haben, weil es sonst vorkommen kann, dass andere Mitglieder, die Artikel schon bestellt haben, und sie aber später abholen wollen, keine Artikel mehr vorfinden.
{.is-warning}


## Ablauf

Der Ablauf für Lagerartikel ist wie folgt:

1. Lieferantin anlegen, falls noch nicht existiert (einmalig), siehe [Lieferantinnen](/de/documentation/admin/suppliers)
2. Artikel anlegen (einmalig, bzw. wenn neu), siehe [Lieferantinnen](/de/documentation/admin/suppliers) 
3. Lager-Lieferungen für Lieferantinnen anlegen, um Artikel ins Lager einzubringen. Das ist normal dann der Fall, wenn Lieferungen von Lieferantinnen im Lagerraum angekommen sind, oder am Anfang, wenn das Lager in der Foodsoft eingerichtet wird, und schon Artikel im Lagerraum vorhanden sind.
   1.  Dazu einmalig entweder Artikel der Lieferantin als Lagerartikel kopieren 
   2.  oder neu erstellen.
   3.  Für die Lieferung eine Rechnung an der Foodsoft auf Basis der Rechnung des Lieferanten anlegen
4. Lagerbestellung anlegen. Sobald ein Artikel bestellt ist, verringert sich die Anzahl der verfügbaren Artikel.
5. Lagerbestellung anpassen (falls bestellte Artikel nicht verfügbar waren) und abrechnen
6. zurück zu Punkt 3. oder 4.

# Lager Artikelliste

Menü **Artikel > Lager**

Artikel sind nach Lieferant gruppiert dargestellt. Für schnelleres Auffinden von bestimmten Artikeln bei umfangreicheren Lagerartikellisten die Suchfunktion des Webbrowsers (Strg+F) verwenden.

> Ansichtsoptionen: nicht verfügbare Artikel anzeigen/verstecken: nicht verfügbare Artikel werden standardmäßig nicht angezeigt.
{.is-warning}


## Bedeutung der Spalten

- **Artikel**: Bezeichnung des Artikels, hinterlegt mit einem Link auf die Detailseite zum Artikel  
- **im Lager**: entspricht der Anzahl der Artikel, die sich im Lager befinden sollten, wenn laufende Lagerbestellungen noch nicht abgeholt wurden, und bereits beendete Lagerbestellungen abgeholt und abgerechnet wurden.
- **Davon bestellt**: Artikel, die bestellt wurden, und von denen die Bestellung noch nicht abgerechnet wurde. 
- **Verfügbar**: “Anzahl im Lager” minus “davon bestellt”. Sollte der Anzahl der Artikel entsprechen, die 
  - zum aktuellen Zeitpunkt noch bestellt werden kann
  - aktuell im Lager vorhanden ist, wenn alle Lagerbestellungenbeendet wurden und alle bestellten Artikel auch abgeholt wurden.

|Status|im Lager|Davon bestellt|Verfügbar|realer Bestand | Differenz realer Bestand - verfügbar |
|------|:------:|:------------:|:-------:|:-------------:|:-------------------------------------:|
|10 Stück geliefert                            |      10|        0|       10|            10|  0 |
|2 bestellt, aber noch nicht abgeholt          |      10|        2|        8|            10| +2 |
|2 bestellt und abgeholt                       |      10|        2|        8|             8|  0 | 
|2 bestellt, abgeholt + abgerechnet            |       8|        0|        8|             8|  0 | 
|2 bestellt und nicht abgeholt, aber abgerechnet |     8|        0|        8|            10| +2 |
|nichts bestellt, aber 3 entnommen             |      10|        0|       10|             7| -3 |
|1 vorhanden, bestellt, aber nicht abgerechnet und nicht abgeholt  |  1|  1|  0|          1| +1 |
|ein Artikel wurde entnommen ohne bestellt zu werden  |  1|      0|  1|          0| -1 |


> Es gibt einige Situationen, wo der tatsächlich Lagerstand und der verfügbare, beim Bestellen angezeigte, Lagerstand nicht übereinstimmen. Das kann dazu (ver-)führen, dass Artikel aus dem Lager entnommen werden, obwohl sie nicht verfügbar sind.  In der Lagerbestellung ist die verfügbare Anzahl 0 oder der Artikel scheint gar nicht auf, weil jemand anderer hat sie schon bestellt, aber noch nicht abgeholt. Dadurch ist der Artikel im Lager vorhanden, lässt sich aber nicht bestellen. Obwohl in dieser Situation der Artikel nicht aus dem Lager entnommen werden darf, passiert es trotzdem.  Umgekehrt kann es passieren, dass Artikel entnommen werden, ohne bestellt worden zu sein, z.B. weil die Bestellung nicht gespeichert wurde oder ein anderer Artikel entnommen wird als bestellt wurde. In dem Fall passiert es dann, dass ein bestellter und laut Foodsoft verfügbarer Artikel im Lager nicht vorhanden ist. 
{.is-warning}


## Detailansicht Lagerartikel

Unter **Artikel > Lager** auf die Bezeichnung eines Artikels klicken, um zur Detailansicht zu gelangen.

### Artikelinfos

- Lieferantin
- Name
- Einheit
- Nettopreis
- MwSt
- Pfand
- Endpreis
- Kategorie
- Notiz
- im Lager
- Verfügbarer Bestand


### Artikel Bearbeiten

Nur Name, Einheit, Kategorie und Notiz können bearbeitet werden. Preis, Mwst und Pfand können nicht bearbeitet werden, dazu muss eine Kopie des Artikels angelegt werden. Der Artikel muss einen anderen Namen haben. Dazu kann z.B. im neuen Artikel Jahr und Monat in der Form 2025-08 hinzugefügt werden, damit klar ist, welcher der aktuelle ist. 
> Der Lagerstand eines Artikels kann ebenfalls nicht bearbeitet werden, aber durch eine **Inventur** angepassst werden. 
{.is-info}



### Verlauf des Lagerbestands

Der Verlauf des Lagerstands wird angezeigt, wobei berücksichtigt werden:
- Lagerbestellungen: nur bereits abgerechntete  
- Lieferungen 
- Inventuren


## Lagerartikel neu anlegen

Lieferantin und Artikel anlegen: siehe [Lieferantinnen](/de/documentation/admin/suppliers). 

> Lagerartikel können erst neu angelegt oder von der Lieferantin in die Lagerartikelliste übernommen werden, wenn eine konkrete Lieferung erfolgt, siehe unten.
{.is-info}

## Lagerartikel löschen
Wenn ein Artikel nicht mehr benötigt wird, indem der Bestand 0 ist und der Artikel zu diesem Preis nicht mehr ins Lager geliefert werden wird, sollte er gelöscht werden. Er scheint zwar bei Lager Bestellungen nicht auf, jedoch z.B. bei der Inventur, was dann mit der Zeit unübersichtlich wird, wenn mehrere ähnliche Artikel existieren, von denen die meisten jedoch nicht mehr verwendet werden. 

> Nach dem Löschen ist der Artikel in der Foodsoft nicht mehr sichtbar, aber in der Datenbank weiterhin vorhanden und kann so auch wieder hergestellt werden. 
{.is-warning}


> Wie viele unbenutzte Artikel auf einmal gelöscht werden können, findest du hier: [Datenbank Beispiele: unbenutzte Lagerartikel entfernen](/de/documentation/admin/datenbank#unbenutzte-lagerartikel-entfernen)
{.is-info}


# Lagerartikel bei Lieferantin bestellen

## Variante 1: Bestellen über die Foodsoft

Wenn eine Bestellung für die Mitglieder bei einer Lieferantin angelegt ist, können auch Artikel fürs Lager bei dieser Lieferantin mitbestellt werden: 

Bestellen \> Bestellverwaltung \> Bestellung anzeigen \> Lagerbestellung. 

Es kann auch eine Bestellung nur für eine Lagerbestellung angelegt werden, um eine Bestellliste für die Lieferantin zu erstellen, und dann die Bestellung gleich wieder geschlossen werden, wenn nicht erwünscht ist, dass Mitglieder bei der Lieferantin direkt bestellen. Eine Funktion, die es ermöglicht, bestimmte Artikel nur für die Lagerbestellung freizuschalten, aber nicht für Mitglieder (z.B. Öl-Lieferantin: Kanister Großgebinde 5L nur für Lagerbestellung, 1L-Flaschen für Mitglieder) gibt es derzeit noch nicht.


> Wie bei den Bestellungen beschrieben, kann nach Abschluss der Bestellung eine Bestellliste z.B. im PDF-Format erstellt und die Lieferantin geschickt werden. 
Der Vorteil ist, dass bei dieser Bestellliste auch die in der Foodsoft hinterlegten Preise angeführt werden, und der Lieferant rückmelden kann, wenn diese nicht stimmen. Besonders bei vielen verschiedenen Artikeln ist diese Methode oft einfacher, wenn Foodcoop-Mitglieder direkt mitbestellen sollen, ist diese Variante ein Muss.  
{.is-success}


> Leider gibt es in der Foodsoft noch keine Verknüpfung der Funktionen Lagerbestellung und Lieferung, sodass in jedem Fall die Anzahl der gelieferten Artikel in der Funktion „Lieferung“ (siehe nächster Abschnitt) neu eingegeben werden muss, unabhängig davon, ob dies bereits bei einer Lagerbestellung vorher erfolgt ist. 
{.is-danger}

>Da beim Anlegen der Rechnung und Zuordnung einer gemeinsamen Bestellung für Bestellgruppen und Lager sowie der Lieferung ins Lager der Lageranteil doppelt berücksichtigt würde, wird in diesem Fall empfohlen, nach beendeter Bestellung mit *Bestellung in Empfang nehmen* die Artikel der Lager-Lieferung herauszunehmen (d.h. die Stückzahl für jeden Artikel um die Ajeweilige Anzahl der Lagerartikel zu reduzieren), und bei *Bestellung abrechnen* die Bestellungen fürs Lager ebenfalls auf 0 zu setzen.
{.is-danger}



## Variante 2: Bestellung Lagerartikel ohne Foodsoft

Alternativ kann eine Bestellung fürs Lager auch direkt bei der Lieferantin z.B. per Telefon, Email oder über einen Webshop erfolgen, ohne die Foodsoft zu verwenden. 

> Besonders bei wenigen Artikeln ist diese Variante oft die einfachere. 
{.is-success}


> Wichtig ist auch in diesem Fall der nächste Schritt, nämlich über eine Lieferung die Artikel ins Lager einzubringen.
{.is-warning}

# Lieferung: Artikel ins Lager einbringen

**Artikel \> Lager \> neue Lieferung.. \> Lieferantin**

1. Einmalig bei der ersten Lieferung,  falls es neue Artikel gibt, oder sich der Preis geändert hat: 
   -  Lagerartikel aus Artikel der Lieferantin anlegen (empfohlen, Vorteil: Artikel der Lieferantin kann verändert und neu ins Lager übernommen werden, während Lagerartikel nur gelöscht und neu angelegt werden kann); alternativ:
   -  Lagerartikel neu anlegen (ohne vorher Artikel bei Lieferantin angelegt zu haben; Nachteil: Lagerartikel kann bei Änderungen nur gelöscht und neu angelegt werden)
1. Lagerartikel auswählen und jeweils gelieferte Stückzahl eingeben
1. Im Notizfeld deinen Namen eingeben
1. [Rechnung](/de/documentation/admin/finances/invoices) anlegen

Details siehe **Tutorial - Lagerartikel anlegen und einbringen.pdf**

> Empfehlung: trage in das Notizfeld der Lieferung deinen Namen ein, damit später nachvollziehbar ist, wer sie angelegt hat. Die Foodsoft zeigt nicht an, wer Lieferungen erstellt hat.
{.is-info}

> Preise von Lagerartikeln können nicht geändert werden. Wenn eine neue Lieferung mit einem anderen Preis ankommt, muss der Lagerbestand der alten Artikel Null sein, damit dieser Lagerrtikel gelöscht werden und mit einem anderen Preis neu angelegt werden kann. Ansonsten muss für die neuen Artikel ein weiterer Lagerartikel mit dem neuen Preis unter einer anderen Artikelbezeichnung angelegt werden, z.B. "Rosinen" (Altbestand) und "Rosinen 2021-05" für die neuen). 
{.is-warning}

# Rechnung für Lieferung anlegen

Anlegen möglich 
1. direkt nach Eingabe der Lieferung, oder
1. jederzeit (auch später) über Rechnung > neue Rechnung anlegen > Lieferant > Lieferung anhand Datum auswählen


# Lagerbestellung für Mitglieder anlegen

Die Lagerbestellung ermöglich es den Foocoop Mitgliedern, Artikel aus dem Lager zu bestellen. Diese Bestellung scheint dann für Mitglieder bei den anderen Bestellungen mit dem Lieferantinnenname **Lager** auf. 

**Artikel \> Lager \> Lagerbestellung online stellen** - dazu ist die Berechtigung **Artikel** oder **Lieferantinnnen** erforderlich. Die Bestellung scheint dann unter Bestellungen > Bestellverwaltung auf und kann dort noch bearbeitet werden.

Wenn eine Lagerbestellung anlegt wird, werden automatisch nur jene Artikel übernommen, wo der zu diesem Zeitpunkt in der Foodsoft aktuelle Lagerstand größer als Null ist. Wenn der Lagerstand ursprünglich Null ist, und sich der Lagerstand später wieder erhöht, z.B. durch eine Inventur oder  eine Lieferung, wird dieser Artikel von der Foodsoft nicht automatisch in laufende Bestellungen aufgenommen, sondern erst in jene Bestellungen, die nach der Lagerstandsänderung angelegt werden. In so einem Fall könnt ihr die offenen Lager-Bestellungen bearbeiten und die entsprechenden Artikel hinzufügen, damit sie gleich verfügbar sind. 


Tipps: 

- Wöchentlich eine Lagerbestellung mit dem üblichen Abholtag der anderen Bestellungen anlegen (z.B. Lagerbestellung Sonntag bis Mittwoch, Abholung Freitag). Diese Lagerbestellung scheint dann in den Bestelllisten unter Bestellen \> Abholtage auf.
- Wöchentlich eine Lagerbestellung für spontan bei der Abholung mitzunehmende Artikel anlegen, zeitversetzt zur ersten Lagerbestellung (Beispiel: Mittwoch bis Dienstag). Hier können Lagerartikel bestellt werden, bevor sie spontan mitgenommen werden. Allerdings kommt es trotzdem immer wieder vor, dass Mitglieder Artikel mitnehmen, ohne sie vorher zu bestellen (z.B. weil sie dazu gerade keine Zeit haben, oder auch weil sie die Artikel in der Foodsoft Lagerbestellung gerade nicht finden), dann aber zuhause feststellen, dass der Artikel gar nicht bestellbar ist, meist deshalb, weil ihn bereits wer anderer bestellt, aber noch nicht abgeholt hatte.



# Inventur anlegen

Erfahrungsgemäß stimmt nach einger Zeit der tatsächliche Lagerstand oft nicht mit dem in der Foodsoft zusammen, weil Artikel bestellt, aber nicht abgeholt werden, oder umgekehrt. Daher ist es von Zeit zu Zeit notwendig, eine Inventur durchzuführen, um den Lagerbestand in der Foodsoft dem tatsächlichen anzupassen, siehe unten. Eine Inventur ist aber nur sinnvoll, wenn gerade keine laufende Lagerbestellung offen ist, und alle bisher bestellten Lagerartikel auch schon abgeholt wurden. 

Empfehlungen daher: 
- Bisherige Lagerbestellungen vorher beenden (und abrechnen?): Während der Inventur darf keine Lagerbestellung offen sein. 
- Mitglieder informieren, dass 
  - vor der Inventur alle bis dahin bestellten Lagerartikel abgeholt werden müssen (oder sonst Bescheid geben: “habe Artikel X bestellt, aber komme erst nach der Inventur dazu, ihn abzuholen”), sodass nicht abgeholte Artikel bei der Erfassung des Lagerbestands berücksichtigt werden können ; 
  - während der Inventur keine Lagerbstellung (und wie sonst auch keine Abholung ohne Bestellung) möglich ist.
  - Neue Lagerbestellung erst nach Abschluss der Inventur starten

Lagerstand Inventurliste = “Verfügbar” aus Lagerliste

> Inventurbilanz als Geldbetrag anzeigen:
> [*https://github.com/foodcoops/foodsoft/issues/856*](https://github.com/foodcoops/foodsoft/issues/856)
{.is-danger}
