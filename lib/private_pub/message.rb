module PrivatePub
  class Message

    attr_reader :message

    def initialize(message)
      @message = message
    end

    def channel
      if is_subscription?
        @message['subscription']
      else
        @message['channel']
      end
    end

    def is_subscription?
      @message['channel'] == '/meta/subscribe'
    end

    def is_meta?
      @message['channel'] =~ %r{^/meta/}
    end

    def needs_authenticating?
      is_subscription? || !is_meta?
    end

    def action
      if is_subscription?
        :subscribe
      else
        :publish
      end
    end

    def prepare!
      if needs_authenticating? && !validator.valid?
        add_error!(validator.error)
      end
    end

  private

    def validator
      NullValidator.new('Authentication required')
    end

    def add_error!(error_message)
      @message['error'] = error_message
    end

  end
end