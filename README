== What is rb++?

Rb++ makes it almost trivially easy to create Ruby extensions for any C++
C++ library. In the simplest of cases, there is no need to ever
touch C++, everything is done in a very simple and clean Ruby API.

For wrapping plain C libraries, I highly recommend FFI: http://github.com/ffi/ffi

Note: For those familiar with py++, the similarities are minimal.
Outside of the purpose of both libraries, rb++ was built from scratch to
provide a Ruby-esque query and wrapping API instead of being a port. However,
many thanks to Roman for his work, the major inspiration for this library.

== Requirements

* rbgccxml
* rice (http://rice.rubyforge.org)

== Installation

Rice builds and installs on any *nix system, including Mac OS X. 
Rice and rb++ have been shown to work under Cygwin and MinGW / MSYS.

  gem install rbplusplus

== The Project

Rb++'s source is in a git repository hosted on github:

http://github.com/jasonroelofs/rbgplusplus/tree/master

Clone with:

  git clone git://github.com/jasonroelofs/rbplusplus.git

== Getting Started

All rb++ projects start off with the Extension class:

  require 'rbplusplus'
  include RbPlusPlus

  Extension.new "extension_name"

Rb++ has one requirement on the C++ code: it must be wrapped in a namespace. If the code
you're trying to wrap is not in it's own namespace, please build a seperate header file that
wraps everything in a namespace as such:

  namespace to_wrap {
    #include "file1.h"
    #include "file2.h"
    #include "file3.h"
    ...
  }

Extension has two ways of being used: block syntax for simple projects and immediate
syntax for more control over the whole process.

=== Block Mode

For most extension wrapping needs, Block Mode takes care of automating everything that it can:

  Extension.new "extension" do |e|
    ...
  end

=== Immediate Mode

For those that want more fine-grained control over the parsing / building / writing / compiling
process, immediate syntax is also available

  e = Extension.new "extension"
  ...
  e.build    # => Generates the C++ code
  e.write    # => Writes out to files
  e.compile  # => Compiles the extension

Please note the ##build ##write and ##compile methods. These are required for an extension to be
built and must be called in this order. These calls are made automatically in Block Mode.
See the RbPlusPlus::Extension class for more details.

== Basic Usage

For the most basic usage, there are only two required calls: Extension.sources and
Extension.namespace. Extension.sources has a few ways to be called
(which takes most the same parameters as RbGCCXML.parse):

  # A single header file
  Extension.new "extension" do |e|
    e.sources "/path/to/header.h"
  end

  # An array of header files
  Extension.new "extension" do |e|
    e.sources ["/path/to/header.h", "/path/there.h"]
  end

  # A glob
  Extension.new "extension" do |e|
    e.sources "/path/to/*.h"
  end

  # An array of globs
  Extension.new "extension" do |e|
    e.sources ["/path/to/*.h", "/elsewhere/*.hpp"]
  end

Once your sources are defined, you need to tell rb++ the name of the namespace from which
code needs to be wrapped. This is done using the #namespace command in one of two different
situations:

  # Wrap all code under the 'to_wrap' namespace
  Extension.new "extension" do |e|
    e.namespace "to_wrap"
  end

When wrapping code under ruby modules, you specify which namespace should be wrapped into
which module as so:

  # Wrap all code under the 'to_wrap' namespace
  Extension.new "extension" do |e|
    e.module "ExtMod" do |m|
      m.namespace "to_wrap"
    end

    e.module "Util" do |m|
      m.namespace "to_wrap_util"
    end
  end

The general rule is this: If you want C++ code wrapped, you must use Extension#namespace to specify
where your C++ code will get wrapped.

When working in Immediate Mode, there is one more required method after ##sources and ##namespace:
##working_dir=, which you use to specify which directory to write out the Rice source code.
When using Block Mode, rb++ can figure out a good default working directory due to __FILE__ on the
block's binding. Without this block, rb++ is clueless and must be told where it's working directory
should be:

  e = Extension.new "extension"
  e.working_dir = "/path/to/generate/files/"

== More Detailed Usage

Because C++ does not easily wrap into Ruby code for many reasons, rb++ is much more capable than just
the basic usage above. There are many different features available to help define and build the wrapper.

=== Modules

An extension can include modules in which code will be wrapped. Any given module needs to either be given
a ##namespace call or be directly given code nodes to wrap using Module#includes.
This specifies which C++ code will be wrapped into this module.

  Extension.new "extension" do |e|
    e.sources ...
    # If there is no global-space code to be wrapped
    # #namespace is not required here

    e.module "MyModule" do |m|
      # We want to wrap all code in ::my_module into this ruby module
      m.namespace "my_module"
    end
  end

=== Particularly hairy APIs

It's well known that source code may not follow a very clean format, or even be internally consistent.
When dealing with such problems -- code that just won't adhere to a wrappable format -- rb++ opens up a slew
of manipulation routines for controlling exactly what gets wrapped, where it gets wrapped, and how
it gets wrapped.

==== Ignoring

Often times you will want to ignore a method on an object, a whole class, or a whole namespace even.  This
can be useful if the function you wish to ignore takes a 'void *' as an argument, or for a variety of other
reasons.

You can tell rb++ which namespaces/classes/methods to ignore very easily:

  Extension.new "extension" do |e|
    e.sources ...
    node = e.namespace "Physics"
    node.classes("Callback").ignore                           # Ignore classes named Callback
    node.classes("Shape").methods("registerCallback").ignore  # Ignore the method Shape::registerCallback
  end

You can also ignore a whole set of query results with the same notation:


  Extension.new "extension" do |e|
    ...
    node.methods.find(:all, :name => "free").ignore           # Ignores all instance methods named 'free'
    ...
  end

==== Including

For more control over exactly where a given piece of C++ code will be wrapped, use Module#includes:

  Extension.new "extension" do |e|
    e.sources ...
    node = e.namespace "PhysicsMath"

    e.module "Physics" do |m|
      m.module "Math" do |math|
        # Moves each class in ::PhysicsMath to Physics::Math.
        # Not the best example but gets the point across. The proper
        # way to do this is to do math.namespace "PhysicsMath" here
        node.classes.each do |c|
          math.includes c
        end
      end
    end

  end

Note that when you include something in a module it is moved from it's original location.  In the example above
the classes will only exist in Physics::Math and will no longer show up in the global space.

==== Renaming

Sometimes C++ libraries implement certain architectures that are nice to have in C++, but are terrible in Ruby, 
or standards in Ruby aren't possible in C++ (func?, func=, func!). For this reason, every node can be renamed using
the #wrap_as method:

  Extension.new "extension" do |e|
    e.sources ...
    node = e.namespace "Physics"
    node.classes("CShape").wrap_as("Shape")
    node.classes("CShape").methods("hasCollided").wrap_as("collided?")
  end

Note: <b>rb++ automatically underscores all method names and CamelCases all class names that haven't been 
otherwise changed with ##wrap_as</b>.

==== Function / Method Conversions

C++ APIs can also sometimes expose global functionality you want contained in a class or module. This
kind of wrapping is also trivially easy in rb++. Say you have the function:

  inline int mod(int a, int b) {
    return a%b;
  }

and you want to add it to your Math class as an instance method. Simple, use ##as_instance_method and ##includes:

  mod = node.functions("mod")
  node.classes("Math").includes mod.as_instance_method

  ----

  require 'extension'

  Math.new.mod(1, 2)

== Possible 'Gotchas'

=== Constructor overloading

A current limitation in rice currently does not allow for more than one constructor to be exported.  This
will not be a limitation in future versions of Rice, but for now make sure that only one constructor is wrapped.
This can be done via direct constructor access:

  node.classes("MyClass").constructors[0].ignore

or by querying according to the arguments of the constructor(s) you want to ignore:

  node.classes("MyClass").constructors.find(:arguments => [nil,  nil]) # ignore constructors with 2 arguments

Contrary to ignoring a constructor, you can also expliclty tell rb++ which constructor to use:

  my_class = node.classes("MyClass")
  my_class.use_constructor my_class.constructors[0]

Rb++ will print out a (WARNING) for each class affected by this.

=== Method overloading

Method overloading not currently supported in Rice, thus rb++ has a workaround built in.
All overloaded methods are wrapped in the order that they are presented to gccxml.  For example:

  class System {
    public:
    System() {}
    inline void puts(std::string s) { std::cout << s << std::endl; }
    inline void puts() { puts(""); }
  };

Will be exposed by default like so:

  s = System.new
  s.puts_0("Hello world")
  s.puts_1

You can, however, rename them as you see fit if you tell rb++ how, for example:

  puts_methods = node.classes("System").methods("puts")
  puts_methods[0].wrap_as("puts")

After doing this you can use the methods as follows:

  s = System.new
  s.puts("Hello World")
  s.puts_1

As of right now, there isn't a specific way to say "use this method as the default name", you need to
make sure you ##wrap_as the method you want to stay the same and let the others get the suffix.

== Misc Options

=== File Writing Options

By default, rb++ will write out the extension in multiple files, following the convention of

  extension_name.rb.cpp
  _ClassName.rb.hpp
  _ClassName.rb.cpp
  _ModuleName_ClassName.rb.hpp
  _ModuleName_ClassName.rb.cpp
  ...

This is done to prevent obscenely long compile times, super large code files, or uncompilable extensions due to
system limitations (e.g. RAM) that are common problems with big SWIG projects.

Rb++ can also write out the extension code in a single file (extension_name.cpp) with Extension#writer_mode

  Extension.new "extension" do |e|
    e.writer_mode :single # :multiple is the default
  end

=== Compilation options

Rb++ takes care of setting up the extension to be properly compiled, but sometimes certain
compiler options can't be deduced. Rb++ has options to specify library paths (-L), libraries (-l),
and include paths (-I) to add to the compilation lines, as well as just adding your own flags
directly to the command line. These are options on Extension.sources

  Extension.new "extension" do |e|
    e.sources *header_dirs,
      :library_paths => *paths,       # Adds to -L
      :libraries => *libs,            # Adds to -l
      :include_paths => *includes,    # Adds to -I
      :cxxflags => *flags,            # For those flags that don't match the above three
      :ldflags => *flags,             # For extra linking flags that don't match the above
      :includes => *files,            # For when there are header files that need to be included into the
                                      #   compilation but *don't* get parsed and wrapped
      :include_source_files => *files # A list of source files that will get copied into working_dir and
                                      #   compiled with the extension
      :include_source_dir => dir      # Specify a directory. Rb++ will build up a list of :includes and
                                      #   :include_source_files based on the files in this directory
  end

=== Command Line Arguments

Rb++ exposes a few command line arguments to your wrapper script that allow more find-grained control
over running your script. These options are:

  Usage: ruby build_noise.rb [options]
    -h, --help                       Show this help message
    -v, --verbose                    Show all progress messages (INFO, DEBUG, WARNING, ERROR)
    -q, --quiet                      Only show WARNING and ERROR messages
        --console                    Open up a console to query the source via rbgccxml
        --clean                      Force a complete clean and rebuild of this extension

=== Logging

All logging is simply sent straight to STDOUT except (ERROR) messages which are sent to STDERR. 

Compilation logs are found in [working_dir]/rbpp_compile.log.
