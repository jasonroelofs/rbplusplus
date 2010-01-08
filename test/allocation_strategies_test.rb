require 'test_helper'

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

  # The test here is simple because if the allocation
  # strategies aren't properly defined, the extension
  # won't even compile. GCC will complain about trying to
  # instantiate an object with a non-public constructor
  # and it all dies.
  specify "properly figures out what allocation to do" do
    should.not.raise LoadError  do
      require 'alloc_strats'
    end 

    # Private constructor, public destructor
    assert defined?(NoConstructor)

    # Private constructor and destructor
    assert defined?(Neither)
  end

  specify "can get access to Neither object" do
    n = Neither.get_instance
    n.should.not.be.nil

    n.process(4, 5).should.equal 20
  end

end
