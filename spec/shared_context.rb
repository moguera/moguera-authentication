RSpec.shared_context 'prepare_auth' do
  let(:apikey) { 'apikey' }
  let(:secret) { 'secret' }
  let(:path) { 'path' }
  let(:http_method) { 'POST' }
  let(:content_type) { 'application/json' }
  let(:now) { Timecop.freeze(Time.now) }
  let(:date) { now.httpdate }
  let(:request_token) {
    Moguera::Authentication.new(
        apikey: apikey,
        secret: secret,
        path: path,
        method: http_method,
        date: date,
        content_type: content_type
    ).token
  }
end
