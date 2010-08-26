$:.unshift File.expand_path(File.dirname(__FILE__) + "/../lib")
$:.unshift File.expand_path(File.dirname(__FILE__) + "/generated")

require 'rubygems'
require 'rspec'
require 'rbplusplus'

include RbPlusPlus

module FileDirectoryHelpers
  def full_dir(path)
    File.expand_path(File.join(File.dirname(__FILE__), path))
  end
end

module LoggerHelpers
  def silence_logging
    Logger.stubs(:info)
    Logger.stubs(:warn)
    Logger.stubs(:error)
    Logger.stubs(:debug)
  end
end

module TestHelpers
  def clear_info
    `rm -rf #{full_dir('generated')}/*`
  end
end

RSpec.configure do |config|
  config.include(FileDirectoryHelpers)
  config.include(LoggerHelpers)
  config.include(TestHelpers)

  config.mock_with :mocha

  config.before(:all) do
    clear_info
    silence_logging
  end
end
