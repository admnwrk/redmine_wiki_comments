# frozen_string_literal: true

module RedmineWikiComments
  # has_many ist ein Klassen-Makro und laesst sich nicht per prepend einbringen -
  # daher include mit class_eval. dependent: :destroy ist wichtig, sonst bleiben
  # beim Loeschen einer Wiki-Seite Kommentar-Waisen in der Tabelle liegen.
  # Beim UMBENENNEN einer Seite ist nichts zu tun: die Kommentare haengen an der
  # wiki_page_id, nicht am Titel.
  module WikiPagePatch
    def self.included(base)
      base.class_eval do
        has_many :wiki_comments, dependent: :destroy
      end
    end
  end
end
