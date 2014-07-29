module PrivatePub
  class Signature

    attr_reader :channel, :expires_at, :mac, :action

    def initialize(attributes={})
      @channel = attributes.fetch(:channel) { raise ArgumentError, 'You must specify a channel' }
      @action = (attributes[:action].to_sym if attributes[:action]).tap do |action|
        raise ArgumentError, 'Action must be :publish or :subscribe' unless [:publish, :subscribe].include?(action)
      end
      @expires_at = attributes.fetch(:expires_at) { PrivatePub.js_timestamp + (PrivatePub.config[:signature_expiration] * 1000) }.to_i
      @mac = attributes.fetch(:mac) { generate_mac }
    end

    def to_hash
      {channel: channel, expires_at: expires_at, signature: mac, action: action}
    end

    def valid?
      mac == generate_mac
    end

    def expired?
      expires_at < PrivatePub.js_timestamp
    end

  private

    def generate_mac
      PrivatePub.generate_signature(channel, expires_at, action)
    end

  end
end