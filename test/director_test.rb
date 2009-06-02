require File.dirname(__FILE__) + '/test_helper'

context "Director proxy generation" do

  def setup
    if !defined?(@@director_built)
      super
      @@director_built = true 
      Extension.new "director" do |e|
        e.sources full_dir("headers/director.h")
        e.namespace "director"
      end

      require 'director'
    end
  end

  specify "polymorphic calls extend into Ruby" do
    class MyWorker < Worker
      def process(num)
        num + 10
      end
    end

    h = Handler.new
    h.add_worker(MyWorker.new)

    h.process_workers(5).should.equal 15
  end

  specify "super calls on pure virtual raise exception" do
    class SuperBadWorker < Worker
      def process(num)
        super + 10
      end
    end

    should.raise NotImplementedError do
      SuperBadWorker.new.process(10)
    end
  end

  specify "allows super calls to continue back into C++ classes" do
    class SuperGoodWorker < Worker
      def do_something(num)
        super + 10
      end
    end

    should.not.raise NotImplementedError do
      SuperGoodWorker.new.do_something(10).should.equal 50
    end
  end

  xspecify "implements proxy so that infinite loop can't occur (polymorphism + super())" 

  xspecify "can specify a default return value in the wrapper"

  xspecify "properly adds all constructor arguments"

  xspecify "takes into account renamed methods"

  xspecify "takes into account renamed / moved classes"

  # Is this necessary?
  xspecify "handles superclasses of the class with virtual methods" do
    class QuadWorker < MultiplyWorker
      def process(num)
        num * 4
      end
    end

    h = Handler.new

    h.add_worker(MultiplyWorker.new)
    h.process_workers(5).should.equal 10

    h.add_worker(QuadWorker.new)
    h.process_workers(5).should.equal 40
  end

end
