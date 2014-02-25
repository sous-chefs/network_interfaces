source 'https://rubygems.org'

group :test, :development, :integration do
  gem 'rake'
  gem 'chef', '>= 10.12.0'
end

group :test, :integration do
  gem 'chefspec',   '~> 3.0'
  gem 'foodcritic', '~> 3.0'
  gem 'rubocop',    '~> 0.16'
end

group :integration do
  gem 'berkshelf',  '~> 2.0'
  gem 'test-kitchen',    '~> 1.1'
  gem 'kitchen-vagrant', '~> 0.14'
end
