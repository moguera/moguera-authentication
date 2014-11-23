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

  describe "#authenticate!" do
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

  describe '#authenticate' do
    it 'should be authenticate' do
      user = subject.authenticate do |request_key|
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
      it 'should be return false' do
        expect(
            Moguera::Authentication.new('Mismatch token:signature').authenticate { request }
        ).to eq false
      end
    end
  end

  describe '#extract_access_key_from_token' do
    it 'should be return access_key' do
      expect(
          subject.send(:extract_access_key_from_token, token: 'TEST access_key:signature')
      ).to eq 'access_key'
    end

    describe 'Invalid token' do
      it 'should be raise AuthenticationError with invalid token message' do
        expect {
          subject.send(:extract_access_key_from_token, token: 'invalid_token')
        }.to raise_error(Moguera::Authentication::AuthenticationError, 'Invalid token.')
      end
    end
  end

  describe '#validate_token!' do
    it 'should be validate token' do
      expect(
          subject.send(:validate_token!, server_token: 'test_token', request_token: 'test_token')
      ).to eq true
    end

    describe 'Mismatch token' do
      it 'should be raise AuthenticationError with mismatch token message' do
        expect {
          subject.send(:validate_token!, server_token: 'test1_token', request_token: 'test2_token')
        }.to raise_error(Moguera::Authentication::AuthenticationError, 'Mismatch token.')
      end
    end
  end

  describe '#validate_time!' do
    it 'should be validate time' do
      expect(
          subject.send(:validate_time!, request_time: http_date)
      ).to eq true
    end

    describe 'Invalid allow_time_interval' do
      it 'should be raise ParameterInvalid' do
        subject.allow_time_interval = -1
        expect {
          subject.send(:validate_time!, request_time: http_date)
        }.to raise_error(Moguera::Authentication::ParameterInvalid, 'Please input a positive value.')
      end
    end

    describe 'Expired request' do
      it 'should be raise AuthenticationError' do
        expect {
          subject.send(:validate_time!, request_time: (Time.parse(http_date)-1000).httpdate)
        }.to raise_error(Moguera::Authentication::AuthenticationError, 'Expired request.')
      end
    end
  end
end
