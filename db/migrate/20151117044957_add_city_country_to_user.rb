class AddCityCountryToUser < ActiveRecord::Migration
  def change
    add_column :users, :city_country, :string
  end
end
