# Redmine Wiki Comments

*[English version](README.md)*

Kommentare an Wiki-Seiten. Unterhalb des Seiteninhalts entsteht ein
Diskussionsbereich; jeder Eintrag protokolliert Autor, Zeitstempel und die
Revision der Seite, auf die er sich bezieht:

> Von Christian Möser vor etwa 21 Stunden hinzugefügt. — Revision v12

Die Revisionsangabe ist auf genau diese Fassung der Seite verlinkt.

## Voraussetzungen

* Redmine >= 6.0

## Installation

```bash
cd /pfad/zu/redmine/plugins
git clone https://github.com/admnwrk/redmine_wiki_comments.git
cd ..
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
# Redmine/Container neu starten
```

Deinstallation:

```bash
bundle exec rake redmine:plugins:migrate NAME=redmine_wiki_comments VERSION=0 RAILS_ENV=production
```

## Rechte

Die Rechte hängen im bestehenden Modul **Wiki** und stehen in der
Rollenverwaltung bei den übrigen Wiki-Rechten:

| Recht | Bedeutung |
| --- | --- |
| Wiki-Kommentare ansehen | Diskussion unter der Seite sehen |
| Wiki-Kommentare hinzufügen | neue Kommentare schreiben |
| Eigene Wiki-Kommentare bearbeiten/löschen | eigene Beiträge ändern (ggf. nur innerhalb des Bearbeitungsfensters) |
| Wiki-Kommentare verwalten | alle Beiträge ändern/löschen, ohne Zeitbegrenzung |

Zusätzlich gilt immer die Sichtbarkeit der Wiki-Seite selbst: wer die Seite
nicht sehen darf, sieht auch die Kommentare nicht.

## Konfiguration

*Administration → Plugins → Redmine Wiki Comments*

* **Sortierung** — älteste oder neueste zuerst
* **Bezugsrevision anzeigen** — Revisionsangabe im Kopf jedes Kommentars
* **Bearbeitungsfenster (Minuten)** — wie lange der Verfasser den eigenen
  Beitrag noch ändern darf (0 = unbegrenzt)

## Verhalten im Detail

* Kommentare hängen an der **Seite**, nicht an der Revision — sie bleiben nach
  einer Bearbeitung der Seite sichtbar. Die Revisionsnummer wird beim Anlegen
  festgehalten und bleibt danach unverändert.
* Beim **Umbenennen** einer Seite bleiben die Kommentare erhalten (Bezug über
  die Seiten-ID, nicht über den Titel).
* Beim **Löschen** einer Seite werden ihre Kommentare mitgelöscht.
* Kommentartexte werden mit Redmines eigenem Formatter gerendert (Textile oder
  CommonMark, je nach Instanz) — inklusive Sanitisierung.
* Im **Wiki-Export** (PDF/HTML, `/wiki/index`) erscheinen die Kommentare nicht.
