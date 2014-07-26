require 'spec_helper'

describe PrivatePub::TokenValidator do

  subject { PrivatePub::TokenValidator.new(token) }

  before(:each) do
    stub_config(secret_token: 'correct_token')
  end

  context 'with incorrect token' do
    let(:token) { 'incorrect_token' }

    its(:valid?) { should eq(false) }
    its(:error) { should eq('Incorrect token.') }
  end


  context 'with correct token' do
    let(:token) { 'correct_token' }

    its(:valid?) { should eq(true) }
    its(:error) { should eq(nil) }
  end
end