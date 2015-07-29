json.array!(@donors) do |donor|
  json.extract! donor, :id, :payload
  json.url donor_url(donor, format: :json)
end
