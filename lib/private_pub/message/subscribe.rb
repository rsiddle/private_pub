module PrivatePub
  class Message
    module Subscribe

      def action
        :subscribe
      end

      def needs_authenticating?
        true
      end

      def channel
        @message['subscription']
      end

    end
  end
end