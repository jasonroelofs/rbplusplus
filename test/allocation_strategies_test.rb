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
    lambda do
      require 'alloc_strats'
    end.should_not raise_error(LoadError)

    # Private constructor, public destructor
    lambda do
      NoConstructor
    end.should_not raise_error(NameError)

    # Private constructor and destructor
    lambda do
      Neither
    end.should_not raise_error(NameError)
  end

  specify "can get access to Neither object" do
    n = Neither.get_instance
    n.should_not be_nil

    n.process(4, 5).should == 20
  end

end
