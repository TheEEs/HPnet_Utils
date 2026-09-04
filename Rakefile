require "minitest/test_task"
require 'dotenv'

Dotenv.load ".env.test"

Minitest::TestTask.create(:spec) do |t|
  t.libs << "specx"
  t.warning = false
  t.test_globs = ["spec/**/*_spec.rb"]
end

task :default => :spec
