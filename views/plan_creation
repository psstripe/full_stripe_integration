require_relative 'stripe_key'
require 'stripe'

Stripe.api_key = $PRIVATE_STRIPE_TEST_KEY

# create a subscription plan
  plan = Stripe::Plan.create(
      :amount => 2000,
      :interval => 'month',
      :name => 'Amazing Gold Plan',
      :currency => 'usd',
      :id => 'gold'
    )
  p plan
