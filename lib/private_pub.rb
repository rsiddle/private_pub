require 'openssl'
require 'json'
require 'procto'

require 'faye'

require 'net/http'
require 'net/https'

require 'private_pub/faye_extension'
require 'private_pub/faye_client_extension'

require 'private_pub/message'
require 'private_pub/message_factory'
require 'private_pub/message/publish'
require 'private_pub/message/subscribe'
require 'private_pub/message/signature_auth'
require 'private_pub/message/token_auth'

require 'private_pub/signature'
require 'private_pub/signature/js_builder'

require 'private_pub/signature_validator'
require 'private_pub/token_validator'
require 'private_pub/valid_validator'
require 'private_pub/invalid_validator'

require 'private_pub/engine' if defined? Rails

module PrivatePub
  class Error < StandardError; end

  class << self
    attr_reader :config

    def reset_config
      @config = {}
    end

    def build_client
      Faye::Client.new(config[:server]).tap do |client|
        client.add_extension(FayeClientExtension.new(config[:secret_token]))
      end
    end

    # TODO: Remove this method in favour of using Faye::Client
    # Publish the given data to a specific channel. This ends up sending
    # a Net::HTTP POST request to the Faye server.
    def publish_to(channel, data)
      publish_message(message(channel, data))
    end

    # Sends the given message hash to the Faye server using Net::HTTP.
    def publish_message(message)
      raise Error, 'No server specified, ensure configuration was loaded properly.' unless config[:server]
      url = URI.parse(config[:server])

      form = Net::HTTP::Post.new(url.path.empty? ? '/' : url.path)
      form.set_form_data(:message => message.to_json)

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = url.scheme == 'https'
      http.start {|h| h.request(form)}
    end

    # Returns a message hash for sending to Faye
    def message(channel, data)
      {channel: channel, data: data, ext: { private_pub_token: config[:secret_token] } }
    end

    def generate_signature(channel, timestamp, action)
      digest = OpenSSL::Digest.new('sha1')
      OpenSSL::HMAC.hexdigest(digest, config[:secret_token], [channel, timestamp, action].join)
    end

    def js_timestamp(time=Time.now)
      (time.to_f * 1000).round
    end

    # Returns the Faye Rack application.
    # Any options given are passed to the Faye::RackAdapter.
    def faye_app(options = {})
      options = {:mount => '/faye', :timeout => 25, :extensions => [FayeExtension.new]}.merge(options)
      Faye::RackAdapter.new(options)
    end
  end

  reset_config
end
