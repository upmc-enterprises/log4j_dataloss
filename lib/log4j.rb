if RUBY_PLATFORM =~ /java/
  puts 'Configuring loggers'
  java_import java.io.ByteArrayInputStream

  config = File.read("#{::Rails.root.to_s}/config/log4j_#{Rails.env}.properties.erb")
  config.gsub!(/RAILS_ROOT/, Rails.root.to_s)
  config.gsub!(/RAILS_ENV/, Rails.env.to_s)
  config_as_input_stream = ByteArrayInputStream.new(config.to_java_bytes)

  org.apache.log4j.PropertyConfigurator.configure(config_as_input_stream)
end
