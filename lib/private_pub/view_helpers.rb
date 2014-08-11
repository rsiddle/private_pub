# TODO: Add test for this.

module PrivatePub
  module ViewHelpers
    def setup_private_pub
      builder = PrivatePub::Signature::JsBuilder.new

      content_tag 'script', :type => 'text/javascript' do
        raw(builder.build_initializer)
      end
    end

    def sign_private_pub
      builder = PrivatePub::Signature::JsBuilder.new
      yield builder

      content_tag 'script', :type => 'text/javascript' do
        raw(builder.build_signatures)
      end
    end
  end
end
