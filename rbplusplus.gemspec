RBPLUSPLUS_VERSION = "1.0.2"
Gem::Specification.new do |s|
  s.name = "rbplusplus"
  s.version = RBPLUSPLUS_VERSION
  s.summary = 'Ruby library to generate Rice wrapper code'
  s.homepage = 'http://rbplusplus.rubyforge.org'
  s.rubyforge_project = "rbplusplus"
  s.author = 'Jason Roelofs'
  s.email = 'jameskilton@gmail.com'

  s.description = <<-END
Rb++ combines the powerful query interface of rbgccxml and the Rice library to 
make Ruby wrapping extensions of C++ libraries easier to write than ever.
  END

  s.add_dependency "rbgccxml", "~> 1.0"
  s.add_dependency "rice", "~> 1.4.0"

  patterns = [
    'TODO',
    'Rakefile',
    'lib/**/*.rb',
  ]

  s.files = patterns.map {|p| Dir.glob(p) }.flatten

  s.test_files = [Dir.glob('test/**/*.rb'), Dir.glob('test/headers/**/*')].flatten

  s.require_paths = ['lib']
end

