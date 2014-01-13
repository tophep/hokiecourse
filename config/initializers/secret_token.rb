# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
Scheduler::Application.config.secret_key_base = 'afe53ebb9f1322d743f0d9abd878366527dbdf41348f9ed4d7e59ccc559247bac6e8d787d4d9bb6c826f89ee3b554b6416f3cca89bcda0da59bb18aefc096cc9'
