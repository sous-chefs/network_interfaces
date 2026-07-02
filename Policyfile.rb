# frozen_string_literal: true

name 'network_interfaces'

run_list 'test::default'

cookbook 'network_interfaces', path: '.'
cookbook 'test', path: './test/cookbooks/test'
cookbook 'modules', '>= 0.1.2', git: 'https://github.com/sous-chefs/modules.git', tag: '0.1.3'
cookbook 'line', '~> 4.0', git: 'https://github.com/sous-chefs/line.git', tag: '4.5.22'

Dir.entries('./test/cookbooks/test/recipes').select { |file| file.end_with?('.rb') }.each do |recipe|
  recipe = recipe.delete_suffix('.rb')
  named_run_list :"#{recipe}", "test::#{recipe}"
end
