require 'csv'

arr = []
key_names = ["battery_id"]

CSV.foreach("/Users/Niha/Desktop/battery_type_3_cleaned_up.csv") do |row|
  if $. > 1 && (row[2] != nil)
    row_hash = eval(("{" + row[2].gsub(/[\\]/, "'") + "}").gsub(/([a-z_]+=>)/){|stuffs|'\'' + stuffs.insert(-3, '\'') }).each_key{|k| key_names << k}

  row_hash["battery_id"] = row[1]
   arr<< row_hash

  end
end


CSV.open("ruby_new_data.csv", "wb" ) do |csv|
   csv << key_names.uniq!
   arr.each do |hash|
     csv << key_names.map {|c_name| hash[c_name]}
   end
 end

