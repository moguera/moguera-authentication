require 'spec_helper'

describe Moguera::Authentication do
  include_context "prepare_auth"

  subject {
    Moguera::Authentication.new(
        apikey: apikey,
        secret: secret,
        path: path,
        method: http_method,
        date: date,
        content_type: content_type
    )
  }

  describe "#token" do
    it 'should display the signature token' do
      expect(subject.token).to eq request_token
    end
  end

  describe "#authenticate" do
    it { subject.authenticate { request_token } }
  end
end
