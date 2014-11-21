RSpec.shared_context 'prepare_auth' do
  let(:access_key) { 'apikey' }
  let(:secret_access_key) { 'secret' }
  let(:request_path) { 'path' }
  let(:request_method) { 'POST' }
  let(:content_type) { 'application/json' }
  let(:now) { Timecop.freeze(Time.now) }
  let(:http_date) { now.httpdate }
  let(:request) {
    Moguera::Authentication::Request.new(
        access_key: access_key,
        secret_access_key: secret_access_key,
        request_path: request_path,
        request_method: request_method,
        http_date: http_date,
        content_type: content_type
    )
  }
  let(:request_token) {
    request.token
  }
end
