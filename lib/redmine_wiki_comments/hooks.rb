# frozen_string_literal: true

module RedmineWikiComments
  class Hooks < Redmine::Hook::ViewListener
    # Redmine 6 bietet in app/views/wiki/show.html.erb keinen eigenen Hook am
    # Seitenende. view_layouts_base_content sitzt in layouts/base.html.erb am
    # Ende von #content - also genau unter dem Wiki-Inhalt - und ist ueber
    # Redmine-Versionen hinweg stabil. Deshalb dort einhaengen und selbst auf
    # den richtigen Kontext (wiki#show) einschraenken.
    def view_layouts_base_content(context = {})
      controller = context[:controller]
      return '' unless controller.respond_to?(:controller_name)
      return '' unless controller.controller_name == 'wiki' && controller.action_name == 'show'

      page = controller.instance_variable_get(:@page)
      return '' unless page.is_a?(WikiPage) && page.persisted?

      project = page.wiki&.project
      return '' unless project
      return '' unless User.current.allowed_to?(:view_wiki_comments, project)

      comments = page.wiki_comments.includes(:author).sorted(RedmineWikiComments.sort_order).to_a

      context[:hook_caller].send(
        :render_to_string,
        partial: 'wiki_comments/list',
        locals:  { page: page, comments: comments }
      )
    rescue StandardError => e
      # Ein Fehler hier darf niemals die Wiki-Seite selbst zerlegen.
      Rails.logger.error("[WikiComments] Rendern fehlgeschlagen: #{e.class}: #{e.message}")
      Rails.logger.error(e.backtrace.first(5).join("\n")) if e.backtrace
      ''
    end

    def view_layouts_base_html_head(_context = {})
      <<~CSS.html_safe
        <style>
          .wiki-comments{margin-top:2em;clear:both;}
          .wiki-comments h3{border-bottom:1px solid #ddd;padding-bottom:.2em;}
          .wiki-comments-count{color:#888;font-weight:normal;}
          .wiki-comment{border:1px solid #e4e4e4;border-radius:3px;margin:.6em 0;padding:.4em .8em;}
          .wiki-comment-header{display:flex;align-items:center;gap:.4em;
            border-bottom:1px solid #f0f0f0;padding-bottom:.3em;margin-bottom:.4em;font-size:.9em;color:#666;}
          .wiki-comment-authoring{flex:1 1 auto;}
          .wiki-comment-revision{margin-left:.4em;white-space:nowrap;}
          .wiki-comment-actions{flex:0 0 auto;position:static;float:none;}
          .wiki-comment-body{overflow-x:auto;}
          .wiki-comment-body > :first-child{margin-top:0;}
          .wiki-comment-body > :last-child{margin-bottom:0;}
          .wiki-comment-form-hint{margin-left:.6em;color:#888;font-size:.9em;}
        </style>
      CSS
    end
  end
end
