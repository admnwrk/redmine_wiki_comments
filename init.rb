# frozen_string_literal: true

require_relative 'lib/redmine_wiki_comments'

Redmine::Plugin.register :redmine_wiki_comments do
  name        'Redmine Wiki Comments'
  author      'admnwrk'
  description 'Kommentare an Wiki-Seiten: Diskussion unterhalb des Seiteninhalts, ' \
              'mit Autor, Zeitstempel und der Revision, auf die sich der Kommentar bezieht.'
  version     '1.0.0'
  url         'https://github.com/admnwrk/redmine_wiki_comments'
  author_url  ''

  requires_redmine version_or_higher: '6.0.0'

  settings(
    default: {
      'sort_order'        => 'asc',  # 'asc' = aelteste zuerst, 'desc' = neueste zuerst
      'edit_window'       => '0',    # Minuten, in denen der Autor noch bearbeiten darf (0 = unbegrenzt)
      'show_revision'     => '1'     # Bezugsrevision im Kopf des Kommentars anzeigen
    },
    partial: 'settings/wiki_comments_settings'
  )

  # Erweitert das BESTEHENDE Wiki-Modul (kein zweites Modul), damit die Rechte
  # in der Rollenverwaltung bei den uebrigen Wiki-Rechten stehen.
  project_module :wiki do
    permission :view_wiki_comments,     {}
    permission :add_wiki_comments,      { wiki_comments: [:create] }
    permission :edit_own_wiki_comments, { wiki_comments: %i[edit update destroy] }
    permission :manage_wiki_comments,   { wiki_comments: %i[edit update destroy] }
  end
end

# Redmine laedt Plugins bereits INNERHALB eines to_prepare-Laufs; ein eigenes
# config.to_prepare wuerde in Produktion daher nicht mehr feuern. Deshalb hier
# direkt einbinden - idempotent, damit ein Reload in der Entwicklung nicht
# mehrfach patcht.
unless WikiPage.included_modules.include?(RedmineWikiComments::WikiPagePatch)
  WikiPage.include(RedmineWikiComments::WikiPagePatch)
end
