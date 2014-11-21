require "bundler/gem_tasks"

begin
  require "rspec/core/rake_task"

  RSpec::Core::RakeTask.new(:spec) do |t|
    t.fail_on_error = true
    t.rspec_opts = '--format doc'
  end

  task :default => :spec
rescue LoadError
  # no rspec available
end