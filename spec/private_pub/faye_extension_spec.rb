require 'spec_helper'

describe PrivatePub::FayeExtension do

  let(:token) { 'token' }

  def prepare(message)
    PrivatePub::FayeExtension.new.incoming(message, ->(x) { x })
  end

  before(:each) do
    stub_config(secret_token: token)
    @message = {'channel' => '/meta/subscribe', 'ext' => {}}
  end

  describe '.prepare' do

    context 'with subscriptions' do

      it 'adds an error on an incoming subscription with a bad signature' do
        @message['subscription'] = 'hello'
        @message['ext']['private_pub_signature'] = 'bad'
        @message['ext']['private_pub_timestamp'] = '123'
        message = prepare(@message)

        expect(message['error']).to eq('Incorrect signature.')
      end

      it 'has no error when the signature matches the subscription' do
        signature = PrivatePub::Signature.new(channel: 'hello', action: :subscribe)
        @message['subscription'] = signature.channel
        @message['ext']['private_pub_signature'] = signature.mac
        @message['ext']['private_pub_timestamp'] = signature.timestamp
        message = prepare(@message)
        expect(message['error']).to be_nil
      end

      it 'has an error when signature just expired' do
        stub_config(signature_expiration: 1)

        signature = PrivatePub::Signature.new(timestamp: 123, channel: 'hello', action: :subscribe)
        @message['subscription'] = signature.channel
        @message['ext']['private_pub_signature'] = signature.mac
        @message['ext']['private_pub_timestamp'] = signature.timestamp
        message = prepare(@message)

        expect(message['error']).to eq('Signature has expired.')
      end

    end

    it 'has an error when trying to publish to a custom channel with a bad token' do
      stub_config(secret_token: 'good')

      @message['channel'] = '/custom/channel'
      @message['ext']['private_pub_token'] = 'bad'
      message = prepare(@message)

      expect(message['error']).to eq('Incorrect token.')
    end

    it 'raises an exception when attempting to call a custom channel without a secret_token set' do
      stub_config(secret_token: nil)

      @message['channel'] = '/custom/channel'
      @message['ext']['private_pub_token'] = 'bad'

      expect {
        prepare(@message)
      }.to raise_error('No secret_token config set, ensure private_pub.yml is loaded properly.')
    end

    it 'has no error on other meta calls' do
      @message['channel'] = '/meta/connect'
      message = prepare(@message)

      expect(message['error']).to be_nil
    end

    it "should not let message carry the private pub token after server's validation" do
      stub_config(secret_token: 'good')

      @message['channel'] = '/custom/channel'
      @message['ext']['private_pub_token'] = PrivatePub.config[:secret_token]
      message = prepare(@message)

      expect(message['ext']['private_pub_token']).to be_nil
    end

  end

end
