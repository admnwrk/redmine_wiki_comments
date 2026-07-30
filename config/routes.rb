# frozen_string_literal: true

# Wiki-Seiten werden in Redmine ueber ihren TITEL adressiert (/projects/x/wiki/Titel);
# eine Verschachtelung darunter wuerde mit Redmines eigenen Wiki-Routen kollidieren.
# Deshalb flache Routen - die Seite kommt als wiki_page_id (echte ID) mit.
RedmineApp::Application.routes.draw do
  resources :wiki_comments, only: %i[create edit update destroy]
end
