require 'spec_helper'

describe Moguera::Authentication do
  include_context "prepare_auth"

  let(:validate_signature) {
    Moguera::Authentication.new(
        apikey: apikey,
        secret: secret,
        path: path,
        method: http_method,
        content_type: content_type,
        date: date
    )
  }

  it 'should display the signature token' do
    expect(signature.token).to eq validate_signature.token
  end
end
