module PrivatePub
  class InvalidValidator
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