# frozen_string_literal: true

class WikiCommentsController < ApplicationController
  before_action :find_page,    only: [:create]
  before_action :find_comment, only: %i[edit update destroy]
  before_action :authorize_view

  def create
    @comment = WikiComment.new(
      wiki_page:         @page,
      author:            User.current,
      # Version des Seiteninhalts ZUM ZEITPUNKT des Kommentars festhalten -
      # spaetere Bearbeitungen der Seite aendern daran nichts.
      wiki_page_version: @page.content&.version,
      comments:          comment_text
    )
    return deny_access unless User.current.allowed_to?(:add_wiki_comments, @project)

    if @comment.save
      flash[:notice] = l(:notice_successful_create)
    else
      flash[:error] = @comment.errors.full_messages.join(', ')
    end
    redirect_to_page(@comment.persisted? ? @comment : nil)
  end

  def edit
    return deny_access unless @comment.editable_by?
  end

  def update
    return deny_access unless @comment.editable_by?

    @comment.comments = comment_text
    if @comment.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to_page(@comment)
    else
      flash.now[:error] = @comment.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    return deny_access unless @comment.deletable_by?

    @comment.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to_page(nil)
  end

  private

  def comment_text
    params.dig(:wiki_comment, :comments).to_s
  end

  def find_page
    @page = WikiPage.find(params[:wiki_page_id])
    @project = @page.wiki&.project
    return render_404 unless @project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_comment
    @comment = WikiComment.find(params[:id])
    @page    = @comment.wiki_page
    @project = @comment.project
    return render_404 unless @page && @project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # Sicherheit: die Modul-/Rechteebene allein reicht nicht - erst WikiPage#visible?
  # beruecksichtigt nicht-oeffentliche Projekte und das Recht :view_wiki_pages.
  # Ohne diese Pruefung liessen sich Kommentare zu nicht sichtbaren Seiten lesen
  # oder ueber eine geratene ID anlegen.
  def authorize_view
    return render_403 unless @page&.visible?
    return render_403 unless User.current.allowed_to?(:view_wiki_comments, @project)
  end

  def redirect_to_page(comment)
    redirect_to project_wiki_page_path(
      @project, @page.title,
      anchor: comment&.persisted? ? "comment-#{comment.id}" : 'wiki-comments'
    )
  end
end
