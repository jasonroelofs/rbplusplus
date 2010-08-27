module RbPlusPlus
  # Helper method for getting access to the logger system
  # Special logger that simply prints out to stdout and stderr
  # Can be configured to ignore certain warning messages.
  class Logger
    class << self

      # Tell the logger to print out every message it gets
      def verbose=(val)
        @@verbose = val
      end

      # Tell the logger to be a little quieter
      def quiet=(val)
        @@quiet = val
      end

      def silent!
        @@silent = true
      end

      def verbose?
        @@verbose = false unless defined?(@@verbose)
        @@verbose
      end

      def quiet?
        @@quiet = false unless defined?(@@quiet)
        @@quiet
      end

      def silent?
        @@silent = false unless defined?(@@silent)
        @@silent
      end

      def info(msg)
        $stdout.puts "(INFO) #{msg}" if !quiet? && !silent?
      end

      def warn(type, msg)
        $stdout.puts "(WARNING) #{msg}" if !silent?
      end

      def debug(msg)
        $stdout.puts "(DEBUG) #{msg}" if verbose? && !silent?
      end

      def error(msg)
        $stderr.puts "(ERROR) #{msg}" if !silent?
      end
    end
  end
end
