name             'network_interfaces'
maintainer       'Guilhem Lettron'
maintainer_email 'guilhem.lettron@youscribe.com'
license          'Apache-2.0'
description      'Installs/Configures network on Ubuntu and Debian'
version          '1.0.2'
chef_version     '>= 12.1'

issues_url 'https://github.com/redguide/network_interfaces/issues'
source_url 'https://github.com/redguide/network_interfaces'

supports 'ubuntu', '>= 14.04'
supports 'debian', '>= 8.0'

depends 'modules', '>= 0.1.2'
depends 'line', '~> 0.6.1'
