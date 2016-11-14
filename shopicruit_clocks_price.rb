##
# This script retrieves all Cloks from shopicruit.myshopify.com public API
# and calculates its sum
#
# Requirements: 1. Network connection
# =>            2. Endpoint http://shopicruit.myshopify.com/products.json alive
# =>            3. Same data structure as seen on Nov 14, 2016 (returned by the endpoint)
# Input:        None
# Output:       sum of the prices of clocks available at shopicruit.myshopify.com
# =>            -> It return the sum from clocks holding any SKU (actually, all SKU are = "")
#
# PS1: IN ORDER TO AVOID INCREASING COMPLEXITY (UNLESS IT'S NECESSARY),
# I CONCEIVED THIS APPLICATION AS A HUMBLE SCRIPT, NOT STRUCTURING IT THROUGH CLASSES
# PS2: THE PARAM 'product_type' SEEMS TO WORK ONLY VIA /admin/products.json, NOT
# =>   /products.json. THEREFORE I'M RETREIVING ALL PRODUCTS AND FILTERING THEM HERE
require 'net/http'
require 'uri'
require 'json'

# URL OF THE STORE
SHOPICRUIT_URL = 'http://shopicruit.myshopify.com/products.json'.freeze

# SOME FIELDS AT THE RESPONSE OF A GET REQUEST FOR THE ENDPOINT ABOVE
TARGET_PRODUCT_FIELD = 'product_type'.freeze
CLOCK_TYPE = 'Clock'.freeze
PRODUCTS_FIELD = 'products'.freeze
VARIANTS_FIELD = 'variants'.freeze
PRICE_VARIANT_FIELD = 'price'.freeze

### Network
# Section which creates generic helper functions to handle Network

##
# Create a URI given a URL and some params
# Params: URL -> base URL of this endpoint
# =>      params -> params to be attached to the given URL
# Return: The new URI
def self.create_uri(url, parms)
    uri = URI(url)
    uri.query = URI.encode_www_form(parms)
    uri
end

##
# Create a HTTP/GET request and retrieve its content
# Params: uri -> URI which the request is going to be made
# Return: Either the body of the request or nil (if the request doesn't succeed)
def self.make_get_request(uri)
    response = Net::HTTP.get_response(uri)
    response.is_a?(Net::HTTPSuccess) ? response.body : nil
end

### Filters
# Section which defines generic filters

##
# Create a function which filter an item by a certain value for a given field
# Params: item -> a hash containing one or more fields
# =>      field -> a field at the given item
# =>      value -> a value to be filtered
# Return: True if the given item holds the given field and value and False otherwise
def self.filter_item_by_type(item, field, value)
    item[field] == value
end


### Products
# Section which use functions defined above for retrieving products from shopicruit.myshopify.com

##
# Retrive all products from shopicruit.myshopify.com
# Strategy: Make several requests to 'SHOPICRUIT_URL' increasing the 'page' to be retrived
# =>        at each request. When no more products is returned, return products
# =>        retrived by all previous requests
# Params: None
# Return: List containing all products at shopicruit.myshopify.com
def self.all_products
    params = { page: 0 }
    products = []
    loop do
        params[:page] += 1
            uri = self.create_uri(SHOPICRUIT_URL, params)
            response_body = self.make_get_request(uri)
            current_products = response_body.nil? ? [] : JSON.parse(response_body)[PRODUCTS_FIELD]
            products.concat(current_products)
        break if current_products.empty?
    end
    products
end

##
# Retrive all products from shopicruit.myshopify.com holding a given type
# Params:   type -> type of the desired product
# Return: List containing all products at shopicruit.myshopify.com holding a given type
def self.products_by_type(type)
    self.all_products.select { |product| self.filter_item_by_type(product, TARGET_PRODUCT_FIELD, type) }
end

##
# Calculate the sum of the prices for a list of products (considering its variants)
# Params:   products -> list containg products from a certain Shopify store
# Return: Total price for the given products with 2 decimals
def self.sum_price(products)
    sum = 0.0
    products.each do |product|
        product[VARIANTS_FIELD].each do |variant_product|
            sum += variant_product[PRICE_VARIANT_FIELD].to_f
        end
    end
    sum.round(2)
end

##
# RUN THE SCRIPT :)
all_products = self.products_by_type(CLOCK_TYPE)
# WRITE RESULT TO STDOUT
puts self.sum_price(all_products)
