module PrivatePub
  class Message
    module Publish

      def action
        :publish
      end

      def needs_authenticating?
        true
      end

      def channel
        @message['channel']
      end

    end
  end
end