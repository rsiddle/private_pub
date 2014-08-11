module PrivatePub
  class MessageFactory

    include Procto.call(:create)

    def initialize(message)
      @message = message
    end

    def create
      Message.new(@message).tap do |message|
        if is_subscription?
          message.extend(Message::Subscribe)
        elsif is_publication?
          message.extend(Message::Publish)
        end
        if signature_present?
          message.extend(Message::SignatureAuth)
        elsif token_present?
          message.extend(Message::TokenAuth)
        end
      end
    end

  private

    def is_subscription?
      @message['channel'] == '/meta/subscribe'
    end

    def is_publication?
      @message['channel'] !~ %r{^/meta/}
    end

    def signature_present?
      @message.fetch('ext', {})['private_pub_signature'] != nil
    end

    def token_present?
      @message.fetch('ext', {})['private_pub_token'] != nil
    end

  end
end