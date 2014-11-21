require 'spec_helper'

describe Moguera::Authentication::Request do
  include_context 'prepare_auth'

  subject {
    Moguera::Authentication::Request.new(
        access_key: access_key,
        secret_access_key: secret_access_key,
        request_path: request_path,
        request_method: request_method,
        http_date: http_date,
        content_type: content_type
    )
  }

  it 'should be set the token_prefix' do
    subject.token_prefix = 'TEST'
    expect(subject.token_prefix).to eq 'TEST'
  end

  it 'should be read the token_prefix' do
    expect(subject.token_prefix).to eq 'MOGUERA'
  end

  it 'should be read the access_key' do
    expect(subject.access_key).to eq access_key
  end

  it 'should be read the secret_access_key' do
    expect(subject.secret_access_key).to eq secret_access_key
  end

  it 'should be read the request_path' do
    expect(subject.request_path).to eq request_path
  end

  it 'should be read the request_method' do
    expect(subject.request_method).to eq request_method
  end

  it 'should be read the http_date' do
    expect(subject.http_date).to eq http_date
  end

  it 'should be read the content_type' do
    expect(subject.content_type).to eq content_type
  end

  describe '#token' do
    it 'should be display the signature token' do
      expect(subject.token).to eq request_token
    end
  end

  describe 'Invalid Parameter' do
    it 'should be raise ParameterInvalid Exception' do
      error = "Missing: Access Key, Secret Access Key, Request Path, Date Header, Content-Type Header"
      expect {
        Moguera::Authentication::Request.new(
            access_key: nil,
            secret_access_key: nil,
            request_path: nil,
            request_method: nil,
            http_date: nil,
            content_type: nil
        )
      }.to raise_error(Moguera::Authentication::ParameterInvalid, error)
    end
  end
end