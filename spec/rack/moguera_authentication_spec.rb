require 'spec_helper'

describe Rack::MogueraAuthentication do
  include_context "prepare_auth"

  include TestApplicationHelper
  include Rack::Test::Methods

  let(:test_app) { TestApplicationHelper::TestApplication.new }
  let(:header) {
    {
        'HTTP_AUTHORIZATION' => request_token,
        'CONTENT_TYPE' => content_type,
        'HTTP_DATE' => http_date,
        'REQUEST_PATH' => request_path
    }
  }

  describe "POST /path" do
    let(:app) { Rack::MogueraAuthentication.new(test_app) { 'secret' } }

    it 'should be return 200 OK' do
      post request_path, {}, header

      expect(last_response.status).to eq 200
      expect(last_response.body).to eq 'test'

      expect(last_request.env['moguera.auth'].token).to eq request_token
      expect(last_request.env['moguera.auth'].token_prefix).to eq 'MOGUERA'
      expect(last_request.env['moguera.auth'].access_key).to eq access_key
      expect(last_request.env['moguera.auth'].secret_access_key).to eq secret_access_key
      expect(last_request.env['moguera.auth'].http_date).to eq http_date
      expect(last_request.env['moguera.auth'].request_method).to eq request_method
      expect(last_request.env['moguera.auth'].request_path).to eq request_path
      expect(last_request.env['moguera.auth'].content_type).to eq content_type

    end

    describe 'Invalid secret_access_key' do
      let(:app) { Rack::MogueraAuthentication.new(test_app) { 'invalid' } }

      it "should be exists AuthenticationError in env['moguera.error']" do
        post request_path, {}, header

        expect(last_response.status).to eq 200
        expect(last_response.body).to eq 'test'

        expect(last_request.env['moguera.error'].class).to eq Moguera::Authentication::AuthenticationError
        expect(last_request.env['moguera.error'].message).to eq 'Mismatch token.'
        expect(last_request.env['moguera.error'].request_token).to eq request_token
        expect(last_request.env['moguera.error'].server_request.access_key).to eq access_key
        expect(last_request.env['moguera.error'].server_request.secret_access_key).to eq 'invalid'
      end
    end

    describe 'Invalid header parameter' do
      let(:app) { Rack::MogueraAuthentication.new(test_app) { 'invalid' } }

      it "should be exists ParameterInvalid in env['moguera.error']" do
        header.delete('HTTP_DATE')
        post request_path, {}, header

        expect(last_response.status).to eq 200
        expect(last_response.body).to eq 'test'

        expect(last_request.env['moguera.error'].class).to eq Moguera::Authentication::ParameterInvalid
        expect(last_request.env['moguera.error'].message).to eq 'Missing: Date Header'
      end
    end
  end
end