gem 'pry-byebug', '~> 3.4.0', group: :development
gem 'lograge', '~> 0.4.1'
gem 'logstash-event', '~> 1.2.02'

environment 'config.logger = Logger.new(STDOUT)'
environment 'config.lograge.enabled = true'
environment 'config.lograge.formatter = Lograge::Formatters::Logstash.new'

environment 'config.web_console.whitelisted_ips = "172.0.0.0/8" if defined?(WebConsole)', env: :development
