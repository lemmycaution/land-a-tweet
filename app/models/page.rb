class Page < ActiveRecord::Base
  validates_presence_of :slug, :body
  before_save :parameterize_slug

  def embeddable?
    domains.any?
  end
  
  def domains
    read_attribute(:domains).keep_if{|d| d.present? }
  end

  private

  def parameterize_slug
    self.slug = self.slug.parameterize
  end
end
