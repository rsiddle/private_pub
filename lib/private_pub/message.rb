module PrivatePub
  class Message

    attr_reader :message

    def initialize(message)
      @message = message
    end

    def needs_authenticating?
      false
    end

    def prepare!
      unless valid?
        add_error!(validator.error)
      end
    end

    def valid?
      validator.valid?
    end

  private

    def validator
      @validator ||= if needs_authenticating?
        InvalidValidator.new('Authentication required')
      else
        ValidValidator.new
      end
    end

    def add_error!(error_message)
      @message['error'] = error_message
    end

  end
end