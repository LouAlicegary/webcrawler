class CreateWebsites < ActiveRecord::Migration
  def change
    create_table :websites do |t|
      t.string :name
      t.string :query_url
      t.string :site_prefix
      t.string :resource_xpath
      t.string :navigation_xpath
      t.string :link_xpath
      t.string :title_xpath
      t.string :author_xpath
      t.text :comments
      t.timestamps
    end
  end
end
