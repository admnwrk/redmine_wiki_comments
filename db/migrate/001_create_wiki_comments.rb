# frozen_string_literal: true

class CreateWikiComments < ActiveRecord::Migration[7.0]
  def change
    create_table :wiki_comments do |t|
      t.integer :wiki_page_id, null: false
      t.integer :author_id,    null: false
      # Version des Seiteninhalts zum Zeitpunkt des Kommentars ("Revision v12").
      # Nur informativ - der Kommentar selbst haengt an der Seite, nicht an der
      # Revision, und bleibt daher bei spaeteren Bearbeitungen sichtbar.
      t.integer :wiki_page_version
      t.text      :comments, null: false
      t.timestamp :created_on
      t.timestamp :updated_on
    end

    add_index :wiki_comments, :wiki_page_id
    add_index :wiki_comments, :author_id
  end
end
