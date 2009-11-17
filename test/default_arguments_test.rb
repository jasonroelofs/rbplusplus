require 'test_helper'

context "Default arguments properly exposed" do

  def setup
    if !defined?(@@defargs_built)
      super
      @@defargs_built = true 
      Extension.new "defargs" do |e|
        e.sources full_dir("headers/default_arguments.h")
        e.writer_mode :single
        node = e.namespace "default_args"

        e.module "Inner" do |m|
          m.includes node.functions("module_do")
        end

        node.classes("Directed").director
      end

      require 'defargs'
    end
  end

  specify "global functions" do
    global_do(1, 4, 5).should.equal 20
    global_do(1, 4).should.equal 40
    global_do(1).should.equal 30
  end

  specify "module functions" do
    Inner.module_do(5).should.equal 18
    Inner.module_do(5, 5).should.equal 20
    Inner.module_do(5, 5, 5).should.equal 15
  end

  specify "class instance methods" do
    tester = Tester.new
    tester.concat("this", "that").should.equal "this-that"
    tester.concat("this", "that", ";").should.equal "this;that"
  end

  specify "class static methods" do
    Tester.build("base").should.equal "basebasebase"
    Tester.build("woot", 5).should.equal "wootwootwootwootwoot"
  end

  specify "director methods" do
    d = Directed.new
    d.virtual_do(3).should.equal 30
    d.virtual_do(3, 9).should.equal 27

    class MyD < Directed
      def virtual_do(x, y = 10)
        super(x * 3, y)
      end
    end

    myd = MyD.new
    myd.virtual_do(10).should.equal 300
  end

  specify "throw argument error on bad types" do
    should.raise TypeError do
      global_do(1, "three")
    end
  end

  # See MethodBase#fix_enumeration_value
  specify "properly handle incomplete enums in default values" do
    modify(1).should.equal 11
    modify(1, Ops::ADD).should.equal 11
    modify(1, Ops::REMOVE).should.equal -9
  end

  # Ogre does this to handle some weird pass-back-enum-that-signals-error (Ogre::Frustum::isVisible)
  specify "properly handle incomplete enums arguments with straight integer default values" do
    modify2(1).should.equal 1
    modify2(1, Ops::ADD).should.equal 1
    modify2(1, Ops::REMOVE).should.equal 1
  end

  specify "should properly handle argument type qualifiers like refs and consts" do
    build_strings("I'd ").should.equal "I'd kick-it"
    build_strings("You won't", " do it").should.equal "You won't do it"
  end
end
