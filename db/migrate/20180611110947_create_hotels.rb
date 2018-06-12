class CreateHotels < ActiveRecord::Migration[5.2]
  def change
    create_table :hotels do |t|
      t.string :name
      t.string :address
      t.string :phone
      t.string :intro
      t.string :url
      t.string :longitude
      t.string :latitude
      t.string :category

      t.timestamps
    end
  end
end
