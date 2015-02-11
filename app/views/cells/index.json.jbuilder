json.array!(@cells) do |cell|
  json.extract! cell, :id, :name, :cell_type, :seq, :size, :byte_pos, :bit_pos, :val, :packet_id
  json.url cell_url(cell, format: :json)
end
