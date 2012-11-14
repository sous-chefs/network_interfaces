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

    network_interfaces "br-test" do
      target "172.16.88.2"
      mask "255.255.255.0"
      bridge [ "none" ]
      pre_up "cat /tmp/iptables-create | iptables-restore -n"
      post_down "cat /tmp/iptables-delete | iptables-restore -n"
    end

More documentation later.
