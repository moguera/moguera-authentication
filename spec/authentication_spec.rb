require 'spec_helper'

describe Moguera::Authentication do
  include_context "prepare_auth"

  subject { Moguera::Authentication.new(request_token) }

  it 'should be set allow_time_interval' do
    subject.allow_time_interval = 300
    expect(subject.allow_time_interval).to eq 300
  end

  it 'should be read allow_time_interval' do
    # default 600s
    expect(subject.allow_time_interval).to eq 600
  end

  describe "#authenticate" do
    it 'should be authenticate' do
      user = subject.authenticate! do |request_key|
        Moguera::Authentication::Request.new(
            access_key: request_key,
            secret_access_key: secret_access_key,
            request_path: request_path,
            request_method: request_method,
            http_date: http_date,
            content_type: content_type
        )
      end
      expect(user.access_key).to eq access_key
    end

    describe 'Invalid token' do
      it 'should be raise AuthenticationError with missing request token message' do
        expect {
          Moguera::Authentication.new
        }.to raise_error(Moguera::Authentication::AuthenticationError, 'Missing request token.')
      end

      it 'should be raise AuthenticationError with invalid token message' do
        expect {
          Moguera::Authentication.new('invalid_token').authenticate! { request }
        }.to raise_error(Moguera::Authentication::AuthenticationError, 'Invalid token.')
      end

      it 'should be raise AuthenticationError with mismatch token message' do
        expect {
          Moguera::Authentication.new('Mismatch token:signature').authenticate! { request }
        }.to raise_error(Moguera::Authentication::AuthenticationError, 'Mismatch token.')
      end
    end
  end
end
