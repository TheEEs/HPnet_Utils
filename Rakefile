require "bundler/setup"

Bundler.require :default, :test

require "minitest/test_task"

Dotenv.load ".env.test"

Minitest::TestTask.create(:test) do |t|
  t.libs << "spec"
  t.warning = false
  t.test_globs = ["spec/**/*_test.rb"]
end

task :default => :test
