---
title: Brutto, Netto, Mehrwertsteuer
description: Steuerliches in Foodcoop erfassen und verwalten
published: true
date: 2022-10-30T19:59:38.416Z
tags: 
editor: markdown
dateCreated: 2021-04-22T09:16:46.231Z
---

# Mehrwertsteuer (Österreich)

> Die Mehrwertsteuer (abgekürzt Mwst, auch Umsatzsteuer) ist eine Steuer für Lieferungen oder Leistungen, die nur bei der Letztverbraucherin/dem Letztverbraucher zum Tragen kommt. Der Mehrwertsteuersatz beträgt **grundsätzlich 20 Prozent** (sogenannter "Normalsteuersatz"). Für einige Waren/Dienstleistungen gilt ein ermäßigter Mehrwertsteuersatz z.B. für **Lebensmittel von 10 Prozent**, Details siehe unten. Der ermäßigte Steuersatz von **13 Prozent** kann z.B. unter bestimmten Voraussetzungen für landwirtschaftliche Direktvermarktung herangezogen werden.



Weitere Infos:
- https://www.oesterreich.gv.at/lexicon/M/Seite.991672.html
- https://www.usp.gv.at/steuern-finanzen/umsatzsteuer.html
- Umsatzsteuergesetz: https://www.ris.bka.gv.at/GeltendeFassung.wxe?Abfrage=Bundesnormen&Gesetzesnummer=10004873

## Wie Foodcoops mit Mehrwertsteuer umgehen

Grundsätzlich muss für alle Artikel, die eine Foocoop an ihre Mitglieder weitergibt, eine Mehrwersteuer bezahlt werden. Die Bemessung und Abfuhr der Mehrwertsteuer ist jedoch Aufgabe der Lieferantin. Für die Foodcoop ist es nur wichtig, dass sie von Lieferantinnen Rechnungen bekommen, auf denen vermerkt ist, wieviel Mehrwertsteuer angefallen ist.

> Eine Firma wie z.B. ein Lebensmittelhandel kauft bei Lieferantinnen zu Netto-Preisen ein, muss aber von ihren Kundinnen Bruttopreise verrechnen und die Differenz (= Mehrwertsteuer) dem Finanzamt abführen. Eine Foodcoop ist jedoch keine Firma, weshalb die Lieferantin die Mehrwertsteuerabgabe erledigen muss. 
{.is-info}


Die Preisinformationen z.B. in Form von Preislisten von Lieferantinnen enthalten manchmal Preise ohne Mehrwertsteuer (Netto) oder manchmal mit Mehrwertsteuer (Brutto). Der Foodcoop müssen von den Lieferantinnen immer Bruttobeträge in Rechnung gestellt werden, genauso wie ihren Mitgliedern immer Bruttopreise verrechnet werden müssen. Die Foodcoop reicht die Mehrwertsteuer nur von ihren Mitgliedern an die Lieferantinnen weiter, die sie dann dem Finanzamt zuführen müssen.

> Die Mehrwertsteuer muss beim [Anlegen von Artikeln in der Foodsoft](/de/documentation/admin/suppliers) nicht eingegeben werden. Sie kann eingegeben werden, wenn von der Lieferantin Netto-Preisinformation vorliegen. Wenn die Lieferantin Bruttopreise angibt, ist es übersichtlicher, keine Mehrwersteuer einzugeben (Netto=Brutto, Mehrwertsteuer = 0%). 
{.is-info}


## Netto- und Bruttobeträge in der Foodsoft

Netto und Bruttobeträge werden an verschienden Stellen der Foodsoft angezeigt. Die Bedeutung ist dabei grundsätzlich wie oben beschrieben, allerdings spielt der Pfandbetrag auch eine Rolle, falls vorhanden.

### Nettobetrag

Artikelkosten ohne Mehrwertsteuer und ohne Pfand 

### Bruttobetrag
Artikelkosten mit Mehrwertsteuer und mit Pfand. Die Foodsoft berechnet auch auf das Pfand die  Mehrwersteuer.

> Netto- und Bruttobetrag sind gleich, wenn keine Mehrwersteuer eingegeben wurde, bzw. unterscheiden sich um das Pfand, falls für den Artikel eines eingegeben wurde.
{.is-info}

## Rundungsdifferenzen

Durch folgende unterschiedliche Berechnungsarten der Mehrwertsteuer bei Bestellungen bzw. Rechnungen kann es zu Differenzen im Cent-Bereich kommen:
- Foodsoft: Mehrwertsteuer wird auf einzelen Artikel berechnet und dabei auf Cent gerundet, Gesamtbetrag ist Summe von gerundeten Einzelbeträgen. Beispiel: Artikelpreis netto 2,34 Euro, brutto mit 10% Mwst 2,574 = gerundet 2,57 Euro, davon 10 Stück: 10 * 2,57 = 25,70 Euro.
- Lieferantinnen: Netto Artikelpreise werden für Rechnungsbetrag summiert, auf den Gesamtbetrag wird prozentuell die Mwst aufgeschlagen. Beispiel: Artikelpreis netto 2,34 Euro, davon 10 Stück: 10 * 2,34 = 23,40 Euro, plus 10% Mwst: 25,74. Differenz zu Foodsoft Betrag: 4 Cent!

> Daher ist es vorteilhaft, Nettopreise eher auf den nächsten ganzen Centbetrag aufzurunden, also z.B. 1,10 statt 1,09 Euro. Dadurch können systematische Verluste der Foodcoop vermieden werden, besonders wenn von einer Lieferantin viele Artikel bzw. Einheiten mit kleinen Geldbeträgen bestellt werden.
{.is-info}

> Die Differenz aufgrund von Rundungsfehlern kann maximal 1 Cent pro Artikel ausmachen. Wenn also z.B. insgesamt 60 Artikel bestellt wurden, kann der Fehler nur 60 Cent sein. Eine größere Differenz muss ihre Ursache woanders haben.
{.is-info}

## Mehrwertsteuersätze

### 20% Mehrwertsteuersatz

Der normale Mehrwertsteuersatz beträgt 20 %, ausgenommen die im Folgenden angeführten Lebensmittel und landwirtschaftlichen Produkte.

### 10% Mehrwertsteuersatz

Auszug aus dem Anhang 1 des [Umsatzsteuergesetz](https://www.ris.bka.gv.at/GeltendeFassung.wxe?Abfrage=Bundesnormen&Gesetzesnummer=10004873):
- genießbare **Waren tierischen Ursprungs**: 
  - Fleisch und genießbare Schlachtnebenerzeugnisse, Gelatine 
  - Fische, ausgenommen Zierfische; Krebstiere, Weichtiere und andere wirbellose Wassertiere 
  - Milch und Milcherzeugnisse; 
  - Vogeleier
  - natürlicher Honig 
- **Gemüse** 
- **Früchte** 
- trockene, ausgelöste **Hülsenfrüchte**, auch geschält oder zerkleinert
- **Nüsse** 
- **Gewürze und Kräuter**: Minze, Lindenblüten und –blätter, Salbei, Kamillenblüten, Holunderblüten und anderer Haustee, Hopfen (Blütenzapfen), Lupulin, Rosmarin, Beifuß, Basilikum und Dost in Aufmachungen für den Einzelverkauf als Gewürz
- **Getreide** und Müllereierzeugnisse: 
  - Mehl, Grieß, Flocken, Granulat und Pellets von Kartoffeln 
  - Mehl und Grieß von trockenen Hülsenfrüchten
  - Stärke von Weizen, Mais und Kartoffeln 
- **Ölsamen** und ölhaltige Früchte sowie Mehl daraus 
- **Fette und Öle**:
  - Schweineschmalz und Geflügelfett, Premierjus und Speisetalg
  - genießbare pflanzliche Öle sowie deren Fraktionen, auch raffiniert, jedoch nicht chemisch modifiziert
  - genießbare tierische oder pflanzliche Fette und Öle sowie deren Fraktionen, ganz oder teilweise hydriert, umgeestert, wiederverestert oder elaidiniert, auch raffiniert, jedoch nicht weiterverarbeitet
  - Margarine; genießbare Mischungen oder Zubereitungen von tierischen oder pflanzlichen Fetten und Ölen sowie von Fraktionen verschiedener Fette und Öle dieses Kapitels, ausgenommen genießbare Fette und Öle sowie deren Fraktionen der Position 1516 
- **Zucker** und Zuckerwaren, Süßungsmittel, ausgenommen chemisch reine Fructose und chemisch reine Maltose, 
- **Kakaopulver** ohne Zusatz von Zucker oder anderen Süßmitteln; 
- **Schokolade** und andere kakaohaltige Lebensmittelzubereitungen 
- **Backwaren**: Zubereitungen aus Getreide, Mehl, Stärke oder Milch;  
- Zubereitungen von Gemüse, Früchten, Nüssen oder anderen Pflanzenteilen, ausgenommen Frucht- und Gemüsesäfte
- Milch und Milcherzeugnisse, mit Zusätzen, ausgenommen Zusätze von Kaffee, Tee oder Mate und von Auszügen, Essenzen und Konzentraten aus Kaffee, Tee oder Mate und von Zubereitungen auf der Grundlage dieser Waren 
- **Essig**: Speiseessig und Essigsäure 
- **Salz**: Speisesalz 
- Mischungen von **Riechstoffen** 
- Waren der monatlichen **Damenhygiene** aller Art

> Nicht darunter fallen Lebensmittel wie Kaffee, Teearten wie z.B. schwarzer Tee, Getränke wie Säfte, Bier und Wein  
{.is-warning}

> Während Milcherzeugnisse nur mit 10 % Mwst besteuert werden, sind es bei veganen pflanzlichen Milchersatzprodukten wie z.B. Sojamilch 20 %!
{.is-warning}


### 13% Mehrwertsteuersatz

Manche Landwirte verrechnen einen Einheitssteuersatz von 13 %. 

> Wenn sich wer auskennt, unter welchen  für Foodcoops relevanten Bedingungen dieser Mehrwertsteuersatz zum Einsatz kommen kann, bitte hier ergänzen.
{.is-danger}
