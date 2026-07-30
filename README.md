# Redmine Wiki Comments

*[Deutsche Version](README_de.md)*

Comments on wiki pages. A discussion area appears below the page content; every
entry records its author, a timestamp and the revision of the page it refers to:

> Added by Christian Möser about 21 hours ago. — Revision v12

The revision is linked to exactly that version of the page.

## Requirements

* Redmine >= 6.0

## Installation

```bash
cd /path/to/redmine/plugins
git clone https://github.com/admnwrk/redmine_wiki_comments.git
cd ..
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
# restart Redmine / the container
```

Uninstall:

```bash
bundle exec rake redmine:plugins:migrate NAME=redmine_wiki_comments VERSION=0 RAILS_ENV=production
```

## Permissions

The permissions live in the existing **Wiki** module and appear in the role
administration next to the other wiki permissions:

| Permission | Meaning |
| --- | --- |
| View wiki comments | see the discussion below the page |
| Add wiki comments | write new comments |
| Edit/delete own wiki comments | change your own entries (within the edit window, if configured) |
| Manage wiki comments | change/delete any entry, without a time limit |

The visibility of the wiki page itself always applies on top: whoever cannot see
the page cannot see its comments either.

## Configuration

*Administration → Plugins → Redmine Wiki Comments*

* **Sort order** — oldest or newest first
* **Show referenced revision** — revision info in each comment header
* **Edit window (minutes)** — how long the author may still change their own
  entry (0 = unlimited)

## Details

* Comments belong to the **page**, not to a revision — they stay visible after
  the page is edited. The revision number is recorded when the comment is
  created and does not change afterwards.
* **Renaming** a page keeps its comments (they reference the page id, not the
  title).
* **Deleting** a page deletes its comments.
* Comment texts are rendered with Redmine's own formatter (Textile or
  CommonMark, depending on the instance), including sanitization.
* Comments do not appear in the **wiki export** (PDF/HTML, `/wiki/index`).
