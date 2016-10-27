require_relative 'stripe_key'
require 'sinatra'
require 'stripe'
require 'sqlite3'

Stripe.api_key = $PRIVATE_STRIPE_TEST_KEY

# home page route
get '/' do
  "Welcome to the Stripe store."
end

# order submission route
post '/purchase' do
  # put form data into variables
  token = params[:stripeToken]
  product_id = params[:product_id].to_i
  customer_email = params[:email]

  # look up price of product
  db = SQLite3::Database.new("store.db")
  db.results_as_hash = true
  product = db.execute("SELECT * from PRODUCTS where id=?", product_id).last
  price = product['price']

  # create the charge
  charge = Stripe::Charge.create(
    :amount => price,
    :currency => "usd",
    :source => token,
    :description => customer_email
  )

  # print the charge to the server console
  p charge

  redirect '/purchase_confirmation'
end

get '/purchase_confirmation' do
  "Thank you for your purchase."
end
