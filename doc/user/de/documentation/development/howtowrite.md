---
title: Leitfaden Foodosoft Dokumentation
description: Leitfaden zur Bearbeitung von Beiträgen dieser Foodosoft Dokumentation
published: true
date: 2025-09-09T21:25:25.054Z
tags: 
editor: markdown
dateCreated: 2021-10-06T10:35:36.615Z
---

Dieser Leitfaden bezieht sich auf alle Teile der Dokumentation und soll helfen, einen einheitlichen Standard in Formulierungen und Layout zu erreichen.

# Zugang

## Österreichische Foodcoops
Du musst dich einmalig im [Forum](forum.foodcoops.at) registrieren. Dann kannst du dich auch für die Bearbeitung dieser Wiki-Seiten anmelden:

![wiki-login1.png](/uploads-de/wiki-login1.png)

Anmeldeoption *foodcoops.at*:

![wiki-login3.png](/uploads-de/wiki-login3.png)

Falls du im Forum gerade nicht angemeldet bist, wirst du zur Anmeldeseite des Forums weitergeleitet.

Einmal angemeldet, solltest du bei jeder Seite rechts unten das **Bearbeiten Symbol** sehen:

![wiki-login3.png](/uploads-de/wiki-login3.png)

## Zugang für andere Personen

Bitte wende dich an support@igfoodcoops.at.

# Wiki-JS

Die Funktionsweise des verwendeten Wiki JS ist unter https://docs.requarks.io beschrieben.


> Die Inhalte des Wikis sind auf Github geclont unter https://github.com/foodcoops/user-docs
{.is-info}

> Die Hauptsprache muss auf Niederländisch eingestellt sein, damit *... (Mario bitte ergänzen, das war damit das Klonen funktioniert, oder?) ...* Für Änderungen in den Einstellungen kann sie vorübergehend auf Deutsch oder Englisch umgestellt werden. 
{.is-warning}


## Darstellung von Text/Code Feldern
Während im Preview Text/Code-Felder gut lesbar sind und Zeilennummern enthalten, sind sie in der Seitenansicht schwerer lesbar und enthalten keine Zeilennummern. Der Folgende HTML/Javascript Code ist unter den Wiki-JS Einstellungen unter *Thema > Code-injectie > Head HTML* eingefügt, um das Layout auch im Seitenmodus wie im Preview zu haben:
```
<script> // 2025-08 by MJ: change pre layout in page view to be similar to preview layout 
window.onload = function() {
  let elements = document.getElementsByTagName("pre"); 
  for (let e of elements) {
    e.classList.add("prismjs");
    e.classList.add("line-numbers");
    let code = e.firstChild;
    const n_lines = code.innerText.split(/\r\n|\r|\n/).length;
    const node = document.createElement("span");
    node.setAttribute('aria-hidden', 'true');
    node.className = 'line-numbers-rows';
    for(i=0; i<n_lines; i++) {
      const childnode = document.createElement("span");
      node.appendChild(childnode);
    }
    code.appendChild(node);
  }
};
</script>
```


# Struktur


## Neue Seite anlegen

Neue Seiten anlegen und/oder Inhalte von einer auf die andere Seite verschieben bitte nur in Absprache mit dem aktuellen Kernteam.

> Für neue Seiten bitte [Markdown](https://docs.requarks.io/editors/markdown) verwenden. Unter dem Link findest du auch Infos, welche Markdown Syntax-Elemente in Wiki JS verwendet werden können.
{.is-info}


# Texte

## Verweise auf Menüeinträge, Buttons und Links in der Foodsoft
Kursive Darstellung von *Foodsoft-Menüpunkt > Untermenüpunkt*

Auch für Buttons und Kombination Menü+Buttons/Links verwendet werden: *Foodsoft-Menüpunkt > Untermenüpunkt > Button-Bezeichnung*

Beispiele:
- *Administration > Benutzer/innen*
- *Administration > Benutzer/innen > Neue/n Benutzer/in anlegen*

## Verwendung der Wiki-JS Zitat-Kästen 

### Zitat

Für Beispiele oder persönliche Empfehlungen.

Beispiel:
> Wenn du z.B. zwei Einheiten bestellst, und dann eine und noch eine wegnimmst, ist der Gesamtwert der Bestellung Null. 

### Info
Beispiel:
> Die Angabe einer Telefonnummer ist optional.
{.is-info}


### Erfolg


Beispiele:
> Diese Funktion eignet sich besonders gut, um ...
{.is-success}

> Diese Funktion wurde ... zur Foodsoft hinzugefügt.
{.is-success}

### Warnung

Beispiele:
> Das Löschen einer Lieferantin kann nicht rückgängig gemacht werden.
{.is-warning}



### Fehler
 - Bekannte Fehler oder Mängel der Foodsoft, idealerweise mit Link zum entprechenden Guthab Issue.
 - Hinweise auf fehlende oder zu überarbeitende Stellen der Dokumentation
 - In *Erfolg* umwandeln wenn erledigt

Beispiele:
> Diese Funktion gibt es in der Foodsoft noch nicht (siehe [Github Issue](https://github.com/foodcoops/foodsoft/issues)).
{.is-danger}

> Hier fehlt noch eine Beschreibung und ein Screenshot.
{.is-danger}

## Links zu externen Seiten

möglich/erwünscht: 
- github, ...

nicht erwünscht/zu vermeiden: 
- Seiten, die nicht für alle deutschsprachigen Benutzerinnen zugänglich sind wie z.B. IG-spezifische Seiten  (nur für Foodcoops in Österreich) wie 
      - Forum
      - Nextcloud
      - ...
- Foodcoops
- Lieferantinnen

## Geschlechterspezifische Begriffe

Aus Gründen der Lesbarkeit wird bei geschlechtsspezifischen Begriffen **nur die weibliche Form** verwendet. Beispeile: Benutzerin (Mehrzahl: Benutzerinnen), Lieferantin, Administratorin, ...

Ausgenommen dort, wo Begriffe in der Foodsoft anders hinterlegt sind (z.B. "Benutzer/innen", "Lieferanten") - hier werden im Sinne der Klarheit die Begriffe der Foodsoft übernommen. Längerfristig wäre es gut, auch für die Foodsoft eine einheitliche Vorgehensweise zu vereinbaren und umzusetzen, ideaelerweise in Abstimmung mit der Dokumentation.


# Bilder
## Ablageordner und Namensgebung

- Bitte Bilder ausschließlich anlegen im Ordner: `/upload-de/`
- Image name: `pagedirectory_pagesubdirectory_pagename_imagename.png` oder `.jpg`

Beispiele:
- `uploads-de/admin_orders_bestellung-anlegen-endaktion.png`
- `uploads-de/usage_order_bestellen.png`


## Foodsoft Screenshots
  - Foodsoft Instanz: https://app.foodcoops.at/demo/
  - Breite des Browserfensters: 1000 Pixel (innen)
  - Namen von realen Benutzerinnen, Lieferantinnen: unlesbar machen (ausgrauen); bevorzugt: Fantasienamen in der Demoinstanz verwenden
  - bevorzugtes Bildformat: PNG (.png)


