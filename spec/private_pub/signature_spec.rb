require 'spec_helper'

describe PrivatePub::Signature do

  def signature(*args)
    PrivatePub::Signature.new(*args)
  end

  describe '#initialize' do

    before(:each)do
      stub_config(secret_token: 'token')
    end

    it 'raises ArgumentError if no channel is specified' do
      expect { signature(action: :subscribe) }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError if action is missing' do
      expect { signature(channel: 'chan')  }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError if action is not publish or subscribe' do
      expect { signature(channel: 'chan', action: :something_else) }.to raise_error(ArgumentError)
    end

    it 'initializes with channel and action' do
      expect { signature(action: :subscribe, channel: 'chan') }.to_not raise_error
      expect { signature(action: :publish, channel: 'chan') }.to_not raise_error
    end
  end

  describe '#timestamp' do
    it 'defaults subscription timestamp to current time in milliseconds' do
      sub = signature(channel: '/hello', action: :subscribe, mac: 'mac')
      time = Time.now
      allow(Time).to receive(:now) { time }

      expect(sub.timestamp).to eq((time.to_f * 1000).round)
    end

    it 'assigns custom timestamp' do
      subscription = signature(channel: 'chan', action: :subscribe, mac: 'mac', timestamp: 123)

      expect(subscription.timestamp).to eq(123)
    end
  end

  describe '#server' do
    it 'defaults to server config' do
      stub_config(server: 'server')
      subscription = signature(channel: 'chan', mac: 'mac', action: :subscribe)

      expect(subscription.server).to eq('server')
    end

    it 'assigns custom server' do

      subscription = signature(channel: 'chan', action: :subscribe, mac: 'sig', server: 'server')

      expect(subscription.server).to eq('server')
    end
  end

  describe '#mac' do
    it 'defaults to generated mac' do
      stub_config(secret_token: 'token')
      sub = signature(channel: '/hello', action: :subscribe)

      expect(sub.mac).to eq(PrivatePub.generate_signature(sub.channel, sub.timestamp, sub.action))
    end

    it 'assigns custom mac' do
      subscription = signature(channel: 'chan', action: :subscribe, mac: 123)

      expect(subscription.mac).to eq(123)
    end
  end

end