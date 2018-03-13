require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.log_level = :fatal
  config.color = true
  config.formatter = :documentation
  config.tty = true
  config.platform = 'ubuntu'
  config.version = '16.04'
end
