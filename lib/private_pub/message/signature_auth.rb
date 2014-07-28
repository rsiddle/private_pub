module PrivatePub
  class Message
    module SignatureAuth

      def signature_mac
        @message['ext']['private_pub_signature']
      end

      def signature_expires_at
        @message['ext']['private_pub_expires_at']
      end

      def prepare!
        super
        strip_sensitive!
      end

    private

      def validator
        return super unless needs_authenticating?
        SignatureValidator.new(signature)
      end

      def signature
        @signature ||= Signature.new(channel: channel, expires_at: signature_expires_at, mac: signature_mac, action: action)
      end

      def strip_sensitive!
        @message['ext']['private_pub_signature'] = nil
        @message['ext']['private_pub_expires_at'] = nil
      end

    end
  end
end