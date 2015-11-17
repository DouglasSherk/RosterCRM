json.array!(@leads) do |lead|
  json.extract! lead, :id
  json.url lead_url(lead, format: :json)
end
