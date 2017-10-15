require 'test_helper'

describe "Allocation Strategies" do

  before(:all) do
    Extension.new "alloc_strats" do |e|
      e.sources full_dir("headers/alloc_strats.h")
      node = e.namespace "alloc_strats"
    end
  end

  # The test here is simple because if the allocation
  # strategies aren't properly defined, the extension
  # won't even compile. GCC will complain about trying to
  # instantiate an object with a non-public constructor
  # and it all dies.
  specify "properly figures out what allocation to do" do
    require 'alloc_strats'

    # Private constructor, public destructor
    NoConstructor

    # Private constructor and destructor
    Neither
  end

  specify "can get access to Neither object" do
    n = Neither.get_instance
    n.should_not be_nil

    n.process(4, 5).should == 20
  end

end
