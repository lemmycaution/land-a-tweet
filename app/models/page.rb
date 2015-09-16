class Page < ActiveRecord::Base
  validates_presence_of :slug, :body
  before_save :parameterize_slug

  private

  def parameterize_slug
    self.slug = self.slug.parameterize
  end
end
