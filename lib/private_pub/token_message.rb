module PrivatePub
  class TokenMessage < Message
    def validator
      TokenValidator.new(token)
    end

    def prepare!
      super
      strip_sensitive!
    end

    def token
      @message['ext']['private_pub_token']
    end

  private

    def strip_sensitive!
      @message['ext']['private_pub_token'] = nil
    end
  end
end