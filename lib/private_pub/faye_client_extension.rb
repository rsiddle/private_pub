module PrivatePub
  class FayeClientExtension
    def initialize(token)
      @token = token
    end

    def outgoing(message, callback)
      message['ext'] ||= {}
      message['ext']['private_pub_token'] = @token

      callback.call(message)
    end
  end
end