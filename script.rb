require 'httparty'
require 'net/ftp'
require 'pry'
require 'json'
require 'net/http'
require 'active_support/core_ext/hash'

# API KEY:
KEY = 'Bearer X'

begin
  puts "Opening FTP connection"
  xml_string = ''

  # Login to FTP server
  ftp = Net::FTP.new('ftp.salsify.com')
  ftp.login('usr', 'pass')

  # Download product file
  ftp.getbinaryfile('products.xml', './downloaded-products.xml')
  File.open('./downloaded-products.xml', 'r') do |f|
    xml_string = f.read
  end

  # Convert product file from XML to JSON
  json_string = Hash.from_xml(xml_string).to_json
  json_data = JSON.parse(json_string)

  # For each product, PUT update request to API with new product and print response and status code
  json_data["products"]["product"].each do |product|
    endpoint = "https://app.salsify.com/api/v1/products/#{product["SKU"]}"
    response = HTTParty.put(endpoint,
                            :body => product.to_json,
                            :headers => { "Content-Type" => 'application/json', "Authorization" => KEY})
    puts response.body
    puts response.code
  end
rescue StandardError => error
  puts error.message
ensure
  puts "\nClosing FTP connection"
  ftp.close
end
