require "bundler/setup"
Bundler.require :default

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), %w(.. lib)))

require 'moguera/authentication'
require 'simplecov'
require 'simplecov-rcov'

SimpleCov.start do
  add_filter 'spec'
end
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter

RSpec.configure do |config|

  # Captures the output for analysis later
  #
  # @example Capture `$stderr`
  #
  # output = capture(:stderr) { $stderr.puts "this is captured" }
  #
  # @param [Symbol] stream `:stdout` or `:stderr`
  # @yield The block to capture stdout/stderr for.
  # @return [String] The contents of $stdout or $stderr
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end
end

require 'shared_context'
