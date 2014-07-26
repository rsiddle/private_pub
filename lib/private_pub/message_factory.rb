module PrivatePub
  class MessageFactory

    include Procto.call(:create)

    def initialize(message)
      @message = message
    end

    def create
      if signature_present?
        SignatureMessage.new(@message)
      elsif token_present?
        TokenMessage.new(@message)
      else
        Message.new(@message)
      end
    end

  private

    def signature_present?
      @message.fetch('ext', {})['private_pub_signature'] != nil
    end

    def token_present?
      @message.fetch('ext', {})['private_pub_token'] != nil
    end

  end
end