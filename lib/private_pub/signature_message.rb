module PrivatePub
  class SignatureMessage < Message

    def signature_mac
      signature.mac
    end

    def signature_timestamp
      signature.timestamp
    end

  private

    def validator
      SignatureValidator.new(signature)
    end

    def signature
      @signature ||= Signature.new(channel: channel, timestamp: @message['ext']['private_pub_timestamp'], mac: @message['ext']['private_pub_signature'], action: action)
    end

    def strip_sensitive!
      @message['ext']['private_pub_signature'] = nil
      @message['ext']['private_pub_timestamp'] = nil
    end

  end
end