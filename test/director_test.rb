require 'test_helper'

describe "Director proxy generation" do

  before(:all) do
    Extension.new "director" do |e|
      e.sources full_dir("headers/director.h")

      node = e.namespace "director"

      # As director is pretty complicated to get right
      # automatically for now, we force-specify which
      # classes to have directors set on.
      %w(Worker MultiplyWorker BadNameClass VirtualWithArgs NoConstructor VBase VOne VTwo).each do |k|
        node.classes(k).director
      end

      node.classes("Worker").methods("doProcessImpl").default_return_value(0)

      klass = node.classes("BadNameClass")
      klass.wrap_as("BetterNamedClass")
      klass.methods("_is_x_ok_to_run").wrap_as("x_ok?")
      klass.methods("__do_someProcessing").wrap_as("do_processing")
    end

    require 'director'
  end

  specify "polymorphic calls extend into Ruby" do
    class MyWorker < Worker
      def process(num)
        num + 10
      end
    end

    h = Handler.new
    h.add_worker(MyWorker.new)

    h.process_workers(5).should == 15
  end

  specify "super calls on pure virtual raise exception" do
    class SuperBadWorker < Worker
      def process(num)
        super + 10
      end
    end

    lambda do
      SuperBadWorker.new.process(10)
    end.should raise_error(NotImplementedError)
  end

  specify "allows super calls to continue back into C++ classes" do
    class SuperGoodWorker < Worker
      def do_something(num)
        super + 10
      end
    end

    lambda do
      SuperGoodWorker.new.do_something(10).should == 50
    end.should_not raise_error(NotImplementedError)
  end

  specify "can specify a default return value in the wrapper" do
    class MyAwesomeWorker < Worker
      def do_process_impl(num)
        num + 7
      end

      def process(num)
        num + 8
      end
    end

    w = MyAwesomeWorker.new
    w.do_process(3).should == 10

    h = Handler.new
    h.add_worker(w)

    h.process_workers(10).should == 18
  end

  specify "properly adds all constructor arguments" do
    v = VirtualWithArgs.new 14, true
    v.process_a("hi").should == 16
    v.process_b.should be_true
  end

  specify "takes into account renamed methods / classes" do
    c = BetterNamedClass.new
    c.x_ok?.should_not be_true

    c.do_processing.should == 14
  end

  specify "handles no constructors" do
    class MyThing < NoConstructor
    end

    n = MyThing.new
    n.do_something.should == 4
  end

  specify "only builds method wrappers for virtual methods" do
    class NumberWorker < Worker
      def get_number
        super + 15
      end
    end

    # Super calls still work
    w = NumberWorker.new
    w.get_number.should == 27

    # But polymorphism stops in the C++
    h = Handler.new
    h.add_worker(w)

    h.add_worker_numbers.should == 12
  end

  specify "Directors implement all pure virtual methods up the inheritance tree" do
    vbase = VBase.new
    v1 = VOne.new
    v2 = VTwo.new

    v1.method_one.should == "methodOne"

    lambda do
      v1.method_two
    end.should raise_error(NotImplementedError)

    lambda do
      v1.method_three
    end.should raise_error(NotImplementedError)

    v2.method_one.should == "methodOne"
    v2.method_two.should == "methodTwo"

    lambda do
      v2.method_three
    end.should raise_error(NotImplementedError)
  end

  specify "handles superclasses of the class with virtual methods" do
    class QuadWorker < MultiplyWorker
      def process(num)
        num * 4
      end
    end

    h = Handler.new

    h.add_worker(MultiplyWorker.new)
    h.process_workers(5).should == 10

    h.add_worker(QuadWorker.new)
    h.process_workers(5).should == 40
  end

  specify "multiple files writer properly handles directors and nested nodes" do
    lambda { Worker::ZeeEnum }.should_not raise_error(NameError)
    lambda { Worker::ZeeEnum::VALUE }.should_not raise_error(NameError)

    Worker::ZeeEnum::VALUE.to_i.should == 4
  end

  specify "inheritance types are registered properly" do
    two = VTwo.new
    VBase::process(two).should == "methodTwo"
  end

end
