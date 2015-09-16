class AddDomainsToPage < ActiveRecord::Migration
  def change
    add_column :pages, :domains, :text, array: true, default: []
  end
end
