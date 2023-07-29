class UpdatePixelsValue < ActiveRecord::Migration[6.0]
  def up
    Illust.where(pixels: '92*92').update_all(pixels: '96*96')
  end

  def down
    Illust.where(pixels: '96*96').update_all(pixels: '92*92')
  end
end
