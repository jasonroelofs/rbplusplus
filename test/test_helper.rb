$:.unshift File.expand_path(File.dirname(__FILE__) + "/../lib")
$:.unshift File.expand_path(File.dirname(__FILE__) + "/generated")

require 'rubygems'
require 'test/spec'
require 'rbplusplus'

include RbPlusPlus

class Test::Unit::TestCase

  def full_dir(path)
    File.expand_path(File.join(File.dirname(__FILE__), path))
  end

  def setup
    `rm -rf #{full_dir('generated')}/*`
    Logger.stubs(:info)
    Logger.stubs(:warn)
    Logger.stubs(:error)
    Logger.stubs(:debug)
  end
end
