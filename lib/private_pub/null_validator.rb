module PrivatePub
  class TokenValidator
    def initialize(message)
      @message = message
    end

    def valid?
      false
    end

    def error
      @message
    end

  end
end