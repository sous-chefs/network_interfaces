# network_interfaces

Manages a single `/etc/network/interfaces.d` interface fragment.

## Actions

* `:save` - Creates or updates an interface fragment. Default.
* `:remove` - Removes the interface fragment and managed auto line.

## Properties

* `device` - String, name property. Interface device name.
* `filename` - String, default resource name. Fragment filename under `/etc/network/interfaces.d`.
* `family` - String, default `'inet'`. Address family.
* `type` - String. Explicit interface type.
* `bridge` - true, false, or Array. Bridge ports or `true` for `none`.
* `bridge_stp` - true or false. Bridge STP setting.
* `bond` - true, false, or Array. Bond slaves or `true` for `none`.
* `bond_mode` - String. Bond mode.
* `vlan_dev` - String. VLAN raw device.
* `onboot` - true or false, default `true`. Add an `auto` line for the interface.
* `bootproto` - String. Set to `'dhcp'` for DHCP.
* `target` - String. Static address.
* `gateway` - String. Gateway address.
* `metric` - Integer. Route metric.
* `mtu` - Integer. Interface MTU.
* `mask` - String. Netmask.
* `network` - String. Network address.
* `broadcast` - String. Broadcast address.
* `pre_up` - String or Array. `pre-up` commands.
* `up` - String or Array. `up` commands.
* `post_up` - String or Array. `post-up` commands.
* `pre_down` - String or Array. `pre-down` commands.
* `down` - String or Array. `down` commands.
* `post_down` - String or Array. `post-down` commands.
* `custom` - Hash. Additional rendered interface directives.
* `hotplug` - true or false, default `false`. Add an `allow-hotplug` line.
* `reload_interface` - true or false, default `true`. Run `ifdown`/`ifup` after template changes.

## Examples

### Static interface

```ruby
network_interfaces 'eth1' do
  target '192.0.2.10'
  mask '255.255.255.0'
  gateway '192.0.2.1'
end
```

### Bridge interface

```ruby
network_interfaces 'br-test' do
  target '172.16.88.2'
  mask '255.255.255.0'
  bridge ['none']
end
```
