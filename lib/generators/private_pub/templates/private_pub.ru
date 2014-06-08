# Run with: rackup private_pub.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "faye"
require "private_pub"

require "private_pub/load_config"

Faye::WebSocket.load_adapter('thin')

run PrivatePub.faye_app
