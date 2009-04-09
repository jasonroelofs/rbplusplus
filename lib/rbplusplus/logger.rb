module RbPlusPlus
  # Helper method for getting access to the logger system
  # Special logger that simply prints out to stdout and stderr
  # Can be configured to ignore certain warning messages.
  class Logger
    class << self
      def info(msg)
        $stdout.puts "(INFO) #{msg}"
      end

      def warn(type, msg)
        $stdout.puts "(WARNING) #{msg}"
      end

      def debug(msg)
        $stdout.puts "(DEBUG) #{msg}"
      end

      def error(msg)
        $stderr.puts "(ERROR) #{msg}"
      end
    end
  end
end
