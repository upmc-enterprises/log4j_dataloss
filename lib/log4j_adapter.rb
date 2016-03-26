# Useful resources
# http://squaremasher.blogspot.com/2009/08/jruby-rails-and-log4j.html
# http://stackoverflow.com/questions/8998363/log4j-in-a-jruby-on-rails-app-redirecting-logs-to-a-separate-file

require 'active_support/all'
require 'pp'

if RUBY_PLATFORM =~ /java/

  # Log4jAdapter makes it simpler to use the java Log4j logger with ruby.
  class Log4jAdapter
    include ActiveSupport::BufferedLogger::Severity
    L4JLevel = org.apache.log4j.Level

    # Shortcut constant for L4JLevel log levels
    SEVERETIES = {
      DEBUG => L4JLevel::DEBUG,
      INFO  => L4JLevel::INFO,
      WARN  => L4JLevel::WARN,
      ERROR => L4JLevel::ERROR,
      FATAL => L4JLevel::FATAL,
    }
    # Inverse of log levels
    INVERSE = SEVERETIES.invert

    # Instantiate a new Log4jAdapter with a logger and root logger.
    # @param [String] log_name name of log
    def initialize(log_name)
      @logger = org.apache.log4j.Logger.getLogger(log_name)
      @root = org.apache.log4j.Logger.getRootLogger
    end

    # Convenience method to get logger filename.
    # @return [String] filename
    def filename
      @logger.get_all_appenders.first.get_file
    end

    # Log a message at the provided severity.
    # @param [Integer] severity log level
    # @param [String] message message to log
    # @param [String] progname program name
    # @param [Proc] block block of code that generates the log message
    def add(severity, message = nil, progname = nil, &block)
      message = (message || (block && block.call) || progname).to_s
      @logger.log(SEVERETIES[severity], message) unless message.blank?
    end

    # Get severity of current log.
    # @return [Integer] the effective log level.
    def level
      INVERSE[@logger.getEffectiveLevel]
    end

    # Set severity of current log.
    # @param [Integer] level the log level.
    # @raise [Exception] if given level isn't valid
    def level=(level)
      fail 'Invalid log level' unless SEVERETIES[level.to_i]
      @root.setLevel(SEVERETIES[level.to_i])
    end

    # Check to see if log is enabled for the given severity.
    # @param [Integer] severity log level
    # @return [Boolean] true if logger is enabled for given severity
    def enabled_for?(severity)
      @logger.isEnabledFor(SEVERETIES[severity])
    end

    def add_log_file_appender(filename)
      fa = org.apache.log4j.FileAppender.new
      fa.name = "FileLogger"
      fa.file = filename + ".error"
      fa.layout = org.apache.log4j.PatternLayout.new("%d %m%n")
      fa.threshold = org.apache.log4j.Level::INFO
      fa.append = true
      fa.activateOptions
      @logger.add_appender(fa)
    end

    # Lifted from BufferedLogger
    for severity in ActiveSupport::BufferedLogger::Severity.constants
      class_eval <<-EOT, __FILE__, __LINE__
      def #{severity.downcase}(message = nil, progname = nil, &block)  # def debug(message = nil, progname = nil, &block)
        add(#{severity}, message, progname, &block)                    #   add(DEBUG, message, progname, &block)
      end                                                              # end
      #
      def #{severity.downcase}?                                        # def debug?
        enabled_for?(#{severity})                                           #   DEBUG >= @level
      end                                                              # end
EOT
    end

    # Prints out unsupported method call name
    def method_missing(meth, *args)
      puts "UNSUPPORTED METHOD CALLED: #{meth}"
    end

  end

end
