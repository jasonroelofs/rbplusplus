require 'test_helper'

context "Extension with wrapped classes" do

  def setup
    if !defined?(@@adder_built)
      super
      @@adder_built = true 
      Extension.new "adder" do |e|
        e.sources full_dir("headers/Adder.h"),
          :include_source_files => [
            full_dir("headers/Adder.h"),
            full_dir("headers/Adder.cpp")
          ]
        node = e.namespace "classes"
        adder = node.classes("Adder")

        adder.use_constructor( adder.constructors.find(:arguments => []))
        adder.disable_typedef_lookup

        decl = <<-END
int subtractIntegers(classes::Adder* self, int a, int b) {
  return a - b;
}

int multiplyIntegers(classes::Adder* self, int a, int b) {
  return a * b;
}
        END

        wrapping = <<-END
<class>.define_method(\"sub_ints\", &subtractIntegers);
<class>.define_method(\"mult_ints\", &multiplyIntegers);
END

        adder.add_custom_code( decl, wrapping )
      end

      require 'adder'
    end
  end

  specify "Adder has new custom methods" do
    a = Adder.new
    a.should.respond_to(:sub_ints)
    a.should.respond_to(:mult_ints)

    a.sub_ints(5, 4).should.equal 1
    a.mult_ints(5, 4).should.equal 20
  end

end

