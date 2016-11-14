require 'net/http'
require 'uri'
require 'json'

SHOPICRUIT_URL = 'http://shopicruit.myshopify.com/products.json'.freeze
TARGET_PRODUCT_FIELD = 'product_type'.freeze
CLOCK_TYPE = 'Clock'.freeze
PRODUCTS_FIELD = 'products'.freeze
VARIANTS_FIELD = 'variants'.freeze
PRICE_VARIANT_FIELD = 'price'.freeze
REDUCING_FROM_ZERO = 0.freeze

### Network
def self.create_uri(url, parms)
    uri = URI(url)
    uri.query = URI.encode_www_form(parms)
    uri
end

def self.make_get_request(uri)
    response = Net::HTTP.get_response(uri)
    response.is_a?(Net::HTTPSuccess) ? response.body : nil
end

### Filters
def self.filter_item_by_type(item, field, value)
    item[field] == value
end

### Products
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

def self.products_by_type(type)
    self.all_products.select { |product| self.filter_item_by_type(product, TARGET_PRODUCT_FIELD, type) }
end

def self.sum_price(products)
    sum = 0.0
    products.each do |product|
        product[VARIANTS_FIELD].each do |variant_product|
            sum += variant_product[PRICE_VARIANT_FIELD].to_f
        end
    end
    sum.round(2)
end

all_products = self.products_by_type(CLOCK_TYPE)
puts self.sum_price(all_products)
