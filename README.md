Description
===========

Manage /etc/network/interfaces on debian / Ubuntu

Requirements
============

ifupdown-0.7~alpha3 or older :
* debian >= squeeze
* Ubuntu >= 11.04 (natty)

Attributes
==========

Usage
=====
example for a bridge with pre-up and pre-down script :

``` ruby
include_recipe 'network_interfaces'
network_interfaces 'br-test' do
  target '172.16.88.2'
  mask '255.255.255.0'
  bridge [ 'none' ]
  pre_up 'cat /tmp/iptables-create | iptables-restore -n'
  post_down 'cat /tmp/iptables-delete | iptables-restore -n'
end
```

Example with multiple addresses on one interface in CIDR (up/down attribs as array):
``` ruby
include_recipe 'network_interfaces'
network_interfaces 'eth1' do
  target '172.16.88.2/24' 
  up ['ip addr add 172.16.88.3/24 dev eth1', 'ip addr add 172.16.88.4/24 dev eth1']
  down ['ip addr del 172.16.88.3/24 dev eth1', 'ip addr del 172.16.88.4/24 dev eth1']
end
```

It will be converted to

```
auto eth1
iface eth1 inet static
  address 172.16.88.2/24
      up ip addr add 172.16.88.3/24 dev eth1
      up ip addr add 172.16.88.4/24 dev eth1
      down ip addr del 172.16.88.3/24 dev eth1
      down ip addr del 172.16.88.4/24 dev eth1
```
More documentation later.
