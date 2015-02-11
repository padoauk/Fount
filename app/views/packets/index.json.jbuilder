json.array!(@packets) do |packet|
  json.extract! packet, :id, :name_space, :name, :version, :is_active, :period
  json.url packet_url(packet, format: :json)
end
