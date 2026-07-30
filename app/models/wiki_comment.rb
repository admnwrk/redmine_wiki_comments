# frozen_string_literal: true

class WikiComment < ActiveRecord::Base
  belongs_to :wiki_page
  belongs_to :author, class_name: 'User'

  validates :comments, presence: true, length: { maximum: 65_000 }
  validates :wiki_page_id, :author_id, presence: true

  scope :sorted, ->(dir = 'asc') {
    order(created_on: (dir.to_s == 'desc' ? :desc : :asc), id: (dir.to_s == 'desc' ? :desc : :asc))
  }

  def project
    wiki_page&.wiki&.project
  end

  # Sichtbarkeit haengt ausschliesslich an der Seite: wer die Seite nicht sehen
  # darf, darf auch die Diskussion dazu nicht sehen.
  def visible?(user = User.current)
    p = project
    !!(p && wiki_page.visible?(user) && user.allowed_to?(:view_wiki_comments, p))
  end

  def editable_by?(user = User.current)
    p = project
    return false unless p && user.logged?
    return true if user.allowed_to?(:manage_wiki_comments, p)

    author_id == user.id &&
      user.allowed_to?(:edit_own_wiki_comments, p) &&
      within_edit_window?
  end
  alias deletable_by? editable_by?

  # Nachtraeglich bearbeitet? (Vergleich mit Sekunden-Toleranz, weil created_on
  # und updated_on beim Anlegen nicht garantiert identisch sind.)
  def edited?
    created_on.present? && updated_on.present? && (updated_on - created_on) > 1
  end

  private

  def within_edit_window?
    minutes = RedmineWikiComments.edit_window
    return true if minutes.zero? || created_on.blank?

    created_on > minutes.minutes.ago
  end
end
