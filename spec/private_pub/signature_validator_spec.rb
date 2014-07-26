require 'spec_helper'

describe PrivatePub::SignatureValidator do

  subject { PrivatePub::SignatureValidator.new(signature) }

  context 'with signature with wrong mac' do
    let(:signature) { instance_double('Signature', valid?: false, expired?: false) }

    its(:valid?) { should eq(false) }
    its(:error) { should eq('Incorrect signature.') }
  end


  context 'with expired signature' do
    let(:signature) { instance_double('Signature', valid?: true, expired?: true) }

    its(:valid?) { should eq(false) }
    its(:error) { should eq('Signature has expired.') }
  end


  context 'with correct signature' do
    let(:signature) { instance_double('Signature', valid?: true, expired?: false) }

    its(:valid?) { should eq(true) }
    its(:error) { should eq(nil) }
  end


end