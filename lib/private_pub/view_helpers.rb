module PrivatePub
  module ViewHelpers
    # Publish the given data or block to the client by sending
    # a Net::HTTP POST request to the Faye server. If a block
    # or string is passed in, it is evaluated as JavaScript
    # on the client. Otherwise it will be converted to JSON
    # for use in a JavaScript callback.
    def publish_to(channel, data = nil, &block)
      PrivatePub.publish_to(channel, data || capture(&block))
    end

    # Subscribe the client to the given channel. This generates
    # some JavaScript calling PrivatePub.sign with the signature
    # options.
    def auth_subscribe(channel)
      generate_signature(channel, :subscribe)
    end

    def auth_publish(channel)
      generate_signature(channel, :publish)
    end

  private

    # REVIEW: Is adding private view helpers a good idea?
    def generate_signature(channel, action)
      signature = PrivatePub::Signature.new(channel: channel, action: action)
      content_tag 'script', :type => 'text/javascript' do
        raw("PrivatePub.sign(#{signature.to_hash.to_json});")
      end
    end
  end
end
