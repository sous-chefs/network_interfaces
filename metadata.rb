# frozen_string_literal: true

name             'network_interfaces'
maintainer       'Sous Chefs'
maintainer_email 'help@sous-chefs.org'
license          'Apache-2.0'
description      'Provides resources to manage /etc/network/interfaces on Debian and Ubuntu'
version          '3.0.0'
chef_version     '>= 15.3'

issues_url 'https://github.com/sous-chefs/network_interfaces/issues'
source_url 'https://github.com/sous-chefs/network_interfaces'

supports 'ubuntu', '>= 22.04'
supports 'debian', '>= 12.0'

depends 'modules', '>= 0.1.2'
depends 'line', '~> 4.0'
