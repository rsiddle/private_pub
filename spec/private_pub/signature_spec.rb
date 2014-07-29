require 'spec_helper'

describe PrivatePub::Signature do

  def signature(*args)
    PrivatePub::Signature.new(*args)
  end

  before(:each) do
    stub_config(signature_expiration: 10)
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

  describe '#expires_at' do
    it 'defaults subscription timestamp to current time + signature expiry' do
      sub = signature(channel: '/hello', action: :subscribe, mac: 'mac')
      time = Time.now
      allow(Time).to receive(:now) { time }

      expect(sub.expires_at).to eq( ( (time.to_f + PrivatePub.config[:signature_expiration]) * 1000).round)
    end

    it 'assigns custom timestamp' do
      subscription = signature(channel: 'chan', action: :subscribe, mac: 'mac', expires_at: 123)

      expect(subscription.expires_at).to eq(123)
    end
  end

  describe '#mac' do

    it 'defaults to generated mac' do
      stub_config(secret_token: 'token')
      sub = signature(channel: '/hello', action: :subscribe)

      expect(sub.mac).to eq(PrivatePub.generate_signature(sub.channel, sub.expires_at, sub.action))
    end

    it 'assigns custom mac' do
      subscription = signature(channel: 'chan', action: :subscribe, mac: 123)

      expect(subscription.mac).to eq(123)
    end
  end

  describe '#expired?' do

    before(:each) do
      stub_config(secret_token: 'token')
    end

    it 'says signature has expired when current time is greater than expiration' do
      time = Time.now
      allow(Time).to receive(:now) { time + 1 }
      sig = signature(channel: '/hello', action: :subscribe, expires_at: PrivatePub.js_timestamp(time))
      expect(sig.expired?).to eq(true)
    end

    it 'says signature has not expired when current time is less than expiration' do
      time = Time.now
      allow(Time).to receive(:now) { time - 1 }
      sig = signature(channel: '/hello', action: :subscribe, expires_at: PrivatePub.js_timestamp(time))
      expect(sig.expired?).to eq(false)
    end
  end

end