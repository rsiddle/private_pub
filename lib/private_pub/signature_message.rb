module PrivatePub
  class SignatureMessage < Message

    def signature_mac
      signature.mac
    end

    def signature_expires_at
      signature.expires_at
    end

    def prepare!
      super
      strip_sensitive!
    end

  private

    def validator
      SignatureValidator.new(signature)
    end

    def signature
      @signature ||= Signature.new(channel: channel, expires_at: @message['ext']['private_pub_expires_at'], mac: @message['ext']['private_pub_signature'], action: action)
    end

    def strip_sensitive!
      @message['ext']['private_pub_signature'] = nil
      @message['ext']['private_pub_expires_at'] = nil
    end

  end
end