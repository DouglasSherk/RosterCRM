json.array!(@customers) do |customer|
  json.extract! customer, :id, :name, :next_contact, :quality, :city_country, :description, :user_id
  json.url customer_url(customer, format: :json)
end
