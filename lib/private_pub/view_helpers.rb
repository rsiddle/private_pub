# TODO: Add test for this.

module PrivatePub
  module ViewHelpers
    def sign_private_pub
      builder = PrivatePub::Signature::JsBuilder.new
      yield builder

      content_tag 'script', :type => 'text/javascript' do
        raw(builder.build)
      end
    end
  end
end
