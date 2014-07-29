require 'spec_helper'

describe PrivatePub::Signature::JsBuilder do

  before(:each) do
    stub_config(server: '/faye', secret_token: 'token', signature_expiration: 60);
  end

  let(:builder) { PrivatePub::Signature::JsBuilder.new }

  context 'with signatures' do
    before(:each) do
      builder.subscribe :sub1, :sub2
      builder.publish :pub1, :pub2
    end

    describe '#build' do
      it 'returns signatures' do
        expect(builder.build).to match /var private_pub = new PrivatePub\("\/faye"\);(private_pub.sign\({.*?}\);){4}/
      end
    end
  end

  context 'without signatures' do
    describe '#build' do
      it 'just returns initializer' do
        expect(builder.build).to eq('var private_pub = new PrivatePub("/faye");')
      end
    end
  end

end