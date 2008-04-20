module RbPlusPlus
  # Writer that takes a builder and writes out the code in
  # one single file
  class SingleFileWriter < Writer::Base

    def write
      process_code(builder)

      filename = builder.name
      cpp_file = File.join(working_dir, "#{filename}.rb.cpp")

      File.open(cpp_file, "w+") do |cpp|
        cpp.puts builder.to_s
      end
    end

    protected

    # What we do here is to go through the builder heirarchy
    # and push all the code from children up to the parent, 
    # ending up with all the code in the top-level builder
    def process_code(builder)
      builder.builders.each do |b|
        process_code(b)
      end

      return unless builder.parent

      builder.parent.includes << builder.includes
      builder.parent.body << builder.body
      builder.parent.declarations << builder.declarations
    end

  end
end
