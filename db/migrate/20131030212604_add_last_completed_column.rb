class AddLastCompletedColumn < ActiveRecord::Migration
  def change
    add_column :websites, :last_completed, :datetime
  end
end
