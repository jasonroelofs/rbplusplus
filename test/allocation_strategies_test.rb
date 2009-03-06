require File.dirname(__FILE__) + '/test_helper'

context "Allocation Strategies" do

  def setup
    if !defined?(@@alloc_strat_built)
      super
      @@alloc_strat_built = true 
      Extension.new "alloc_strats" do |e|
        e.sources full_dir("headers/alloc_strats.h")
        node = e.namespace "alloc_strats"
      end
    end
  end

  xspecify "properly figures out what allocation to do" do
    assert_nothing_raised LoadError  do
      require 'alloc_strats'
    end 

    assert defined?(NoConstructor)
    assert defined?(Neither)
  end

end
