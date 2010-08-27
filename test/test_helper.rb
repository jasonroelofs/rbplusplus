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

module TestHelpers
  def clear_info
    `rm -rf #{full_dir('generated')}/*`
  end

  def silence_logging
    RbPlusPlus::Logger.silent!
  end

  def test_setup
    clear_info
    silence_logging
  end
end

RSpec.configure do |config|
  config.include(FileDirectoryHelpers)
  config.include(TestHelpers)

  config.before(:all) do
    test_setup
  end
end
