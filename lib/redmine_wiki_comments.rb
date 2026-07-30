# frozen_string_literal: true

module RedmineWikiComments
  module_function

  def settings
    Setting.plugin_redmine_wiki_comments || {}
  end

  def sort_order
    settings['sort_order'].to_s == 'desc' ? 'desc' : 'asc'
  end

  # Minuten, in denen der Autor seinen eigenen Kommentar noch aendern darf.
  # 0 (oder ungueltig) = unbegrenzt.
  def edit_window
    n = settings['edit_window'].to_i
    n.positive? ? n : 0
  end

  def show_revision?
    settings['show_revision'].to_s != '0'
  end
end

require_relative 'redmine_wiki_comments/wiki_page_patch'
require_relative 'redmine_wiki_comments/hooks'
