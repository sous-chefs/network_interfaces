# network_interfaces

[![Cookbook Version](https://img.shields.io/cookbook/v/network_interfaces.svg)](https://community.opscode.com/cookbooks/network_interfaces)

Provides custom resources for managing `/etc/network/interfaces` on Debian and Ubuntu systems using `ifupdown`.

## Requirements

### Platforms

* Debian 12+
* Ubuntu 22.04+

### Chef

* Chef Infra Client 15.3+

### Cookbooks

* line
* modules

### Gems

* aws-sdk-ec2
* bigdecimal

## Resources

* [network_interfaces_base](documentation/network_interfaces_base.md)
* [network_interfaces](documentation/network_interfaces.md)
* [network_interfaces_eni](documentation/network_interfaces_eni.md)

## Migration

This cookbook no longer ships root recipes or attributes. See [migration.md](migration.md) for the breaking changes and resource examples.
