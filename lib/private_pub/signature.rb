module PrivatePub
  class Signature

    attr_reader :channel, :timestamp, :server, :mac, :action

    def initialize(attributes={})
      @channel = attributes.fetch(:channel) { raise ArgumentError, 'You must specify a channel' }
      @action = attributes[:action].tap do |action|
        raise ArgumentError, 'Action must be :publish or :subscribe' unless [:publish, :subscribe].include?(action)
      end
      @timestamp = attributes.fetch(:timestamp) { (Time.now.to_f * 1000).round }
      @server = attributes.fetch(:server) { PrivatePub.config[:server] }
      @mac = attributes.fetch(:mac) { generate_mac }
    end

    def to_hash
      {server: server, timestamp: timestamp, signature: mac, action: action}
    end

    def valid?
      mac == generate_mac
    end

    def expired?
      PrivatePub.signature_expired?(timestamp)
    end

  private

    def generate_mac
      PrivatePub.generate_signature(channel, timestamp, action)
    end

  end
end