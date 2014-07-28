module PrivatePub
  class Message
    module TokenAuth

      def prepare!
        super
        strip_sensitive!
      end

      def token
        @message['ext']['private_pub_token']
      end

    private

      def validator
        return super unless needs_authenticating?
        TokenValidator.new(token)
      end

      def strip_sensitive!
        @message['ext']['private_pub_token'] = nil
      end
    end
  end
end