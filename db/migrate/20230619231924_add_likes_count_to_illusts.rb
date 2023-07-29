class AddLikesCountToIllusts < ActiveRecord::Migration[6.1]
  def change
    add_column :illusts, :likes_count, :integer, default: 0
  end
end
