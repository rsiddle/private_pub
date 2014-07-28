require 'spec_helper'

describe PrivatePub::MessageFactory do
  describe '.create' do

    def metaclass_of(object)
      class << object; self; end
    end

    it 'does not extend meta channel that is not subscribe' do
      message_hash = { 'channel' => '/meta/connect' }
      message = PrivatePub::MessageFactory.call(message_hash)

      expect(metaclass_of(message).ancestors).to_not include(PrivatePub::Message::Publish)
      expect(metaclass_of(message).ancestors).to_not include(PrivatePub::Message::Subscribe)
    end

    it 'extends publication with publish module' do
      message_hash = { 'channel' => '/channel' }
      message = PrivatePub::MessageFactory.call(message_hash)

      expect(metaclass_of(message).ancestors).to include(PrivatePub::Message::Publish)
      expect(metaclass_of(message).ancestors).to_not include(PrivatePub::Message::Subscribe)
    end

    it 'extends subscription with subscribe module' do
      message_hash = { 'channel' => '/meta/subscribe', 'subscription' => '/channel' }
      message = PrivatePub::MessageFactory.call(message_hash)

      expect(metaclass_of(message).ancestors).to include(PrivatePub::Message::Subscribe)
      expect(metaclass_of(message).ancestors).to_not include(PrivatePub::Message::Publish)
    end
  end
end