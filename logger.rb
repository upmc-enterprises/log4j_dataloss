require 'pp'

class Rails
  def self.env
    'production'
  end

  def self.root
    Dir.pwd
  end
end

message = ARGV[0] || "Default message"

if RUBY_PLATFORM =~ /java/
  include Java
  require 'lib/log4j-1.2.17.jar'
  require 'lib/log4j.rb'
  require 'lib/log4j_adapter.rb'

  logger = Log4jAdapter.new('Rails')
  second_logger = Log4jAdapter.new('second_log')

  pp logger.filename

  counter = 0
  while true do
    logger.error("#{message} : #{counter}")
    second_logger.info("#{message} : #{counter}") if counter%10 == 0
    counter+=1
    sleep 1
  end

else
  pp "JRuby not detected"
end
