# network_interfaces

[![Cookbook Version](https://img.shields.io/cookbook/v/network_interfaces.svg)](https://community.opscode.com/cookbooks/network_interfaces)
[![Travis status](http://img.shields.io/travis/redguide/network_interfaces.svg)](https://travis-ci.org/redguide/network_interfaces)

## Description

Manage `/etc/network/interfaces` on Debian/Ubuntu

## Attributes

* `node['network_interfaces']['replace_orig']` - Replaces `/etc/network/interfaces` if set to `true`

## Usage

example for a bridge with pre-up and pre-down script :

```ruby
include_recipe 'network_interfaces'

network_interfaces 'br-test' do
  target '172.16.88.2'
  mask '255.255.255.0'
  bridge [ 'none' ]
  pre_up 'cat /tmp/iptables-create | iptables-restore -n'
  post_down 'cat /tmp/iptables-delete | iptables-restore -n'
end
```

More documentation later.
