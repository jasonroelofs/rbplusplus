require 'rdoc/task'

task :default => :test

# We test this way because of what this library does.
# The tests wrap and load C++ wrapper code constantly.
# When running all the tests at once, we very quickly run 
# into problems where Rice crashes because 
# a given C++ class is already wrapped, or glibc doesn't like our 
# unorthodox handling of it's pieces. So we need to run the
# tests individually
desc "Run the tests"
task :test do
  require 'rbconfig'
  FileList["test/*_test.rb"].each do |file|
    # To allow multiple ruby installs (like a multiruby test suite), I need to get
    # the exact ruby binary that's linked to the ruby running the Rakefile. Just saying
    # "ruby" will find the system's installed ruby and be worthless
    ruby = File.join(RbConfig::CONFIG["bindir"], RbConfig::CONFIG["RUBY_INSTALL_NAME"])
    sh "#{ruby} -S rspec -Itest #{file}"
  end
end

Rake::RDocTask.new do |rd|
  rd.main = "README"
  rd.rdoc_files.include("README", "lib/**/*.rb")
  rd.rdoc_files.exclude("**/jamis.rb")
  rd.template = File.expand_path(File.dirname(__FILE__) + "/lib/jamis.rb")
  rd.options << '--line-numbers' << '--inline-source'
end
