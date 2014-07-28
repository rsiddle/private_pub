require 'rubygems'
require 'bundler/setup'
require 'faye'
require 'private_pub'

require 'rspec'
require 'rspec/its'

require 'pry'

module RspecHelpers
  def stub_config(config={})
    allow(PrivatePub).to receive(:config).and_return(PrivatePub.config.merge(config))
  end
end

RSpec.configure do |config|
  config.include RspecHelpers
end
