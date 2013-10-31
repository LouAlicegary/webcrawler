class AddWebsiteIdColumn < ActiveRecord::Migration
  def change
    add_column :online_resources, :website_id, :integer
  end
end
