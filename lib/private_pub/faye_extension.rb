module PrivatePub
  # This class is an extension for the Faye::RackAdapter.
  # It is used inside of PrivatePub.faye_app.
  class FayeExtension
    # Callback to handle incoming Faye messages. This authenticates both
    # subscribe and publish calls.
    def incoming(message, callback)

      message = MessageFactory.call(message).tap do |message|
        message.prepare!
      end.message

      callback.call(message)
    end

  end

  def outgoing(message, callback)
    message['data'] = { channel: message['channel'], data: message['data'] }
    callback.call(message)
  end
end
