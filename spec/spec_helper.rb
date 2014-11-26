require "bundler/setup"
Bundler.require :test

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), %w(.. lib)))

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start { add_filter 'spec' }

require 'rack/moguera_authentication'
require 'moguera/authentication'
require 'shared_context'

module TestApplicationHelper
  extend self

  class TestApplication
    def call(env)
      [200, {"Content-Type" => "text/plain"}, ["test"]]
    end
  end
end
