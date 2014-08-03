module PrivatePub
  class Signature
    class JsBuilder
      def initialize
        @signatures = []
      end

      def subscribe(*channels)
        add_signatures(channels, :subscribe)
        self
      end

      def publish(*channels)
        add_signatures(channels, :publish)
        self
      end

      def build
        @signatures.inject(build_initializer) do |string, signature|
          string + build_signature(signature)
        end
      end

    private

      def build_initializer
        "var private_pub = new PrivatePub(#{PrivatePub.config[:server].to_json});"
      end

      def build_signature(signature)
        "private_pub.sign(#{signature.to_hash.to_json});"
      end

      def add_signatures(channels, action)
        signatures = channels.map { |channel| PrivatePub::Signature.new(channel: channel, action: action) }
        @signatures.push(*signatures)
      end
    end
  end
end