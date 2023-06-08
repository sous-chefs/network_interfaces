name             'network_interfaces'
maintainer       'Sous Chefs'
maintainer_email 'help@sous-chefs.org'
license          'Apache-2.0'
description      'Installs/Configures network on Ubuntu and Debian'
version          '2.0.3'
chef_version     '>= 15.0'

issues_url 'https://github.com/sous-chefs/network_interfaces/issues'
source_url 'https://github.com/sous-chefs/network_interfaces'

supports 'ubuntu', '= 18.04'
supports 'debian', '>= 9.0'

depends 'modules', '>= 0.1.2'
depends 'line', '~> 4.0'
