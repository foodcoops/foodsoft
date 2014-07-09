
# Bestellen
Das Bestellen ist der Hauptteil dieser Software und ein wenig kompliziert.
Hier starte ich den Versuch die Programmlogik in Text umzusetzen und
verweise auf die enstprechenden Controller bzw. Modelle.
Der relevante Controller ist `OrdersController`.

## Bestellung "in Netz stellen"
Darunter verstehen wir die Auswahl von Artikeln eines bestimmten Lieferanten fuer eine zeitlich begrenzte
Bestellung im Internet. Die relevanten Methoden sind `OrdersController#newOrder` und folgende.
Jede Bestellung wird durch die Klasse Order abgebildet.

Die zugehoerigen Artikel werden duch die Klasse `OrderArticle` mit den Artikeln verknuepft.
Dabei werden auch die Attribute `quantity`, `tolerance` und `quantity_to_order` gespeichert.
Diese Mengen repraesentieren die Gesamtbestellung, also alle Bestellgruppen.

## Eine Bestellgruppe bestellt...
Die Methode `OrdersController#order` schickt uns die Bestellenseite. Mit dieser
Oberflaeche koennen die Bestellgruppen die vorher ausgewaehlten Artikel
bestellen. Mittels den Buttons werden dabei live, also clientseitig, die
Preise ermittelt und der Gesamtpreis berechnet. Ist der Gesamtpreis groeßer als
der aktuelle Gruppenkontostand, so wird die Preisspalte rot unterlegt und die
Bestellung kann nicht gespeichert werden.

## (gruppen)-Bestellung wird gespeichert

Die Gruppenbestellung wird durch die Tabelle `group_oders` (`GroupOrder`)
abgebildet, bzw. die Bestellung und Bestellgruppe wird dort verknuepft.

Die bestellten Artikel der Bestellgruppe werden durch die Tabelle `group_order_articles`
(`GroupOrderArticle`) registriert. Dort werden nun die Modelle GroupOrder
und OrderArticle miteinander verbunden.

Bei jeder Bestellung wird außerdem die Summe der Menge, Toleranz in `GroupOrderArticle`
abgelegt. Allerdings muss jede Aenderung dieser Mengen mit protokolliert werden.
Dies ist wichtig, weil spaeter die Zuteilung der Einheiten pro bestellten Artikel
nach der chronologischen Reihenfolge erfolgt. (s.u.)
Das passiert dann in der Tabelle `group_order_article_quantities`
(`GroupOrderArticleQuantity`).

## Aenderunug einer Bestellung

Knifflig ist die Aenderung einer gruppenbestellung, weil die zeitliche
Reihenfolge dabei nicht durcheinander geraten darf.
Wir unterscheiden dehalb zwei Faelle:

### Erhoehe die Menge des Arikels.
Jetzt wird eine Zeile in `group_order_article_quantities` angelegt.
und zwar mit genau den Mengen, die zusatzlich bestellt wurden.
Quantity und Tolerance funktionieren analog.

Beispiel:
* Urspruenglich bestellt: 2(2) um 17uhr.
* Erhoehe Bestellung auf 4(2) um 18hur.  
  => neue Zeile mit quantity = 2, tolerance = 0, und created_on = 18uhr
* Jetzt gibt es zwei zeilen die insgesamt 4(2) ergeben.  
  (die summen in `GroupOrderArticle` werden aktualisiert)

### Verringere die Mengen des Artikels.
Jetzt muss chronologisch zurueckgegangen werden und um die urspruenglich bestellten
Mengen zu verringern.

Beispiel von oben:
* Verringe Bestellung auf 2(1) um 19uhr.  
  => Zeile mit created_on = 18uhr wird gelöscht und  
  in der Zeile mit created_on = 17uhr wird der Wert tolerance auf 1 gaendert.

## Wer bekommt wieviel?

Diese Frage wird wie schon erwaehnt mittels der `group_order_article_quantites`-Tabelle
geloest.

Beispiel.

* articel x mit unit_quantity = 5.
  * 17uhr: gruppe a bestellt 2(3), weil sie auf jeden fall was von x bekommen will
  * 18uhr: gruppe b bestellt 2(0)
  * 19uhr: gruppe a faellt ein dass sie doch noch mehr braucht von x und aendert auf 4(1).

* jetzt gibt es drei zeilen in der tabelle, die so aussehen:
  * (gruppe a), 2(1), 17uhr (wurde um 19uhr von 2(3) auf 2(1) geaendert)
  * (gruppe b), 2(0), 18uhr
  * (gruppe a), 2(0), 19uhr.

* die zuteilung wird dann wie folgt ermittelt:
  * zeile 1: gruppe a bekommt 2
  * zeile 2: gruppe b bekommt 2
  * zeile 3: gruppe a bekommt 1, weil jetzt das gebinde schon voll ist.

* Endstand: insg. Bestellt wurden 6(1)
  * Gruppe a bekommt 3 einheiten.
  * gruppe b bekommt 2 einheiten.
  * eine Einheit verfaellt.
