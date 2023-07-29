class CreateCanvas < ActiveRecord::Migration[6.1]
  def change
    create_table :canvas do |t|
      t.string :canvas
      t.string :pixels
      t.integer :user_id
      t.integer :illust_id

      t.timestamps
    end
  end
end
