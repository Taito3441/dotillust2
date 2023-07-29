class AddimageToIllusts < ActiveRecord::Migration[6.1]
  def change
    add_column :illusts, :image, :string
  end
end
