class CreateInteractions < ActiveRecord::Migration
  def change
    create_table :interactions do |t|
      t.belongs_to :customer, index: true, foreign_key: true
      t.datetime :time
      t.integer :mode
      t.string :description

      t.timestamps null: false
    end
  end
end
