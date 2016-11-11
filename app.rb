require_relative 'stripe_key'
require 'sinatra'
require 'stripe'
require 'sqlite3'
require 'json'

Stripe.api_key = $PRIVATE_STRIPE_TEST_KEY

# home page route
get '/' do
  # get list of products -- we'll include these
  # on our store page eventually
  db = SQLite3::Database.new("store.db")
  db.results_as_hash = true
  @products = db.execute("SELECT * from PRODUCTS")

  erb :home

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

    #   # create the charge
    # begin
    #   charge = Stripe::Charge.create(
    #     :amount => price,
    #     :currency => "usd",
    #     :source => token,
    #     :description => customer_email
    #   )
    #
    # rescue Stripe::CardError => e
    # p e # The card has been declined
    # end
    #
    # # print the charge to the server console
    # p charge

  token = params[:stripeToken]

  # subscribe customer
  customer = Stripe::Customer.create(
    :source => token,
    :plan => "gold",
    :email => customer_email
  )

  p customer
  p customer.id

  db = SQLite3::Database.new("store.db")
  db.results_as_hash = true
  db.execute( "INSERT INTO customers (customer_id) VALUES (?)", customer.id )

    subscription = Stripe::Subscription.retrieve(customer.subscriptions.data[0].id)
    subscription.trial_end = 1485734400
    subscription.save

  redirect '/purchase_confirmation'
end

get '/purchase_confirmation' do
  "Thank you for your purchase."

end

# Using Sinatra
post '/webhooks' do
  # Retrieve the request's body and parse it as JSON
  event_json = JSON.parse(request.body.read)

  # Do something with event_json

  status 200

  p event_json
end
