require_relative '../shopicruit_clocks_price'
require 'json'

PRODUCT_TYPE_FIELD = "product_type".freeze
CLOCK_PRODUCT_TYPE_VALUE = "Clock".freeze
PANTS_PRODUCT_TYPE_VALUE = "Pants".freeze
PROD_01_CLOCK = "{\"id\": 1, \"product_type\": \"Clock\", \"variants\": [{\"price\": \"40.44\"}]}".freeze
PROD_02_CLOCK = "{\"id\": 2, \"product_type\": \"Clock\", \"variants\": [{\"price\": \"30.33\"}, {\"price\": \"50.55\"}]}".freeze
PROD_03_PANTS = "{\"id\": 20, \"product_type\": \"Pants\", \"variants\": [{\"price\": \"20.01\"}]}".freeze
RESPONSE_BODY_MOCK = "[#{PROD_01_CLOCK}, #{PROD_03_PANTS}, #{PROD_02_CLOCK}]".freeze
ONLY_CLOKS = "[#{PROD_01_CLOCK}, #{PROD_02_CLOCK}]".freeze
ONLY_PANTS = "[#{PROD_03_PANTS}]".freeze

describe "#filter_item_by_type" do
    before :each do
        @all_products = JSON.parse(RESPONSE_BODY_MOCK)
        @field = PRODUCT_TYPE_FIELD
        @item = @all_products[0]
        @value = CLOCK_PRODUCT_TYPE_VALUE
    end

    it "takes an item, a field and a value and returns that the given item contains a field with the given value" do
        expect(filter_item_by_type(@item, @field, @value)).to eq true
    end

    it "takes an item, a field and a value and returns that the given item doesnt contain a field with the given value" do
        expect(filter_item_by_type(@item, PANTS_PRODUCT_TYPE_VALUE, @value)).to eq false
    end
end

describe "#products_by_type" do
    before :each do
        @all_products = JSON.parse(RESPONSE_BODY_MOCK)
        @field = PRODUCT_TYPE_FIELD
        @only_clocks = JSON.parse(ONLY_CLOKS)
        @only_pants = JSON.parse(ONLY_PANTS)
        # Mock GET request to retrieve all products
        allow_any_instance_of(Object).to receive(:all_products).and_return(@all_products)
    end

    it "takes a list of products and returns only those which are clocks" do
        expect(products_by_type(CLOCK_PRODUCT_TYPE_VALUE)).to eq @only_clocks
    end

    it "takes a list of products and returns only those which are pants" do
        expect(products_by_type(PANTS_PRODUCT_TYPE_VALUE)).to eq @only_pants
    end
end

describe "#sum_prices" do
    before :each do
        @all_products = JSON.parse(RESPONSE_BODY_MOCK)
        @field = PRODUCT_TYPE_FIELD
        @only_clocks = JSON.parse(ONLY_CLOKS)
        @only_pants = JSON.parse(ONLY_PANTS)
    end

    it "takes a list of clocks and returns the sum of ther prices" do
        expect(sum_prices(@only_clocks)).to eq 121.32
    end

    it "takes a list of pants and returns the sum of their prices" do
        expect(sum_prices(@only_pants)).to eq 20.01
    end

    it "takes a list of products and returns the sum of their prices" do
        expect(sum_prices(@all_products)).to eq 141.33
    end
end
