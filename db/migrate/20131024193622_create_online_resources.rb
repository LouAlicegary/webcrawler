class CreateOnlineResources < ActiveRecord::Migration
  def change
    create_table :online_resources do |t|
      t.string :link
      t.string :title
      t.string :author

      t.timestamps
    end
  end
end
