

action :save do
  node.normal['network_interfaces']['order'] =
    (node['network_interfaces']['order'] || []) + [new_resource.device]

  if new_resource.bridge &&
     new_resource.bridge.class != Array
    new_resource.bridge = ['none']
  end

  if new_resource.vlan_dev ||
     new_resource.device =~ /(en|eth|bond|wlan)[0-9]+\.[0-9]+/
    package 'vlan'
    modules '8021q'
  end

  if new_resource.bond &&
     new_resource.bond.class != Array
    new_resource.bond = ['none']
  end

  if new_resource.bond
    package 'ifenslave-2.6'
    modules 'bonding'
  end

  type = if new_resource.bootproto == 'dhcp'
           'dhcp'
         elsif !new_resource.target
           'manual'
         else
           'static'
         end

  up_down_cmd = {
    pre_up: Array(Chef::Recipe::NetworkInterfaces.value(:pre_up, new_resource.device, new_resource, node)),
    up: Array(Chef::Recipe::NetworkInterfaces.value(:up, new_resource.device, new_resource, node)),
    post_up: Array(Chef::Recipe::NetworkInterfaces.value(:post_up, new_resource.device, new_resource, node)),
    pre_down: Array(Chef::Recipe::NetworkInterfaces.value(:pre_down, new_resource.device, new_resource, node)),
    down: Array(Chef::Recipe::NetworkInterfaces.value(:down, new_resource.device, new_resource, node)),
    post_down: Array(Chef::Recipe::NetworkInterfaces.value(:post_down, new_resource.device, new_resource, node)),
  }

  package 'ifmetric' if Chef::Recipe::NetworkInterfaces.value(:metric, new_resource.device, new_resource, node)

  package 'bridge-utils' if new_resource.bridge

  execute "if_up #{new_resource.name}" do
    command "ifdown #{new_resource.device} " \
      "-i /etc/network/interfaces.d/#{new_resource.device} ; " \
      "ifup #{new_resource.device} " \
      "-i /etc/network/interfaces.d/#{new_resource.device}"
    only_if "ifdown -n #{new_resource.device} " \
      "-i /etc/network/interfaces.d/#{new_resource.device} ; " \
      "ifup -n #{new_resource.device} " \
      "-i /etc/network/interfaces.d/#{new_resource.device}"
    action :nothing
  end

  append_if_no_line "insert auto for #{new_resource.device}" do
    line "auto #{new_resource.device}"
    path '/etc/network/interfaces.d/00interfaces'
    only_if { Chef::Recipe::NetworkInterfaces.value(:onboot, new_resource.device, new_resource, node) }
  end

  template "/etc/network/interfaces.d/#{new_resource.filename}" do
    cookbook 'network_interfaces'
    source 'interfaces.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      device:       new_resource.device,
      type:       Chef::Recipe::NetworkInterfaces.value(:type,         new_resource.device, new_resource, node) || type,
      auto:         Chef::Recipe::NetworkInterfaces.value(:onboot,     new_resource.device, new_resource, node),
      family:       Chef::Recipe::NetworkInterfaces.value(:family,     new_resource.device, new_resource, node),
      address:      Chef::Recipe::NetworkInterfaces.value(:target,     new_resource.device, new_resource, node),
      network:      Chef::Recipe::NetworkInterfaces.value(:network,    new_resource.device, new_resource, node),
      netmask:      Chef::Recipe::NetworkInterfaces.value(:mask,       new_resource.device, new_resource, node),
      gateway:      Chef::Recipe::NetworkInterfaces.value(:gateway,    new_resource.device, new_resource, node),
      broadcast:    Chef::Recipe::NetworkInterfaces.value(:broadcast,  new_resource.device, new_resource, node),
      bridge_ports: Chef::Recipe::NetworkInterfaces.value(:bridge,     new_resource.device, new_resource, node),
      bridge_stp:   Chef::Recipe::NetworkInterfaces.value(:bridge_stp, new_resource.device, new_resource, node),
      vlan_dev:     Chef::Recipe::NetworkInterfaces.value(:vlan_dev,   new_resource.device, new_resource, node),
      bond_slaves:  Chef::Recipe::NetworkInterfaces.value(:bond,       new_resource.device, new_resource, node),
      bond_mode:    Chef::Recipe::NetworkInterfaces.value(:bond_mode,  new_resource.device, new_resource, node),
      metric:       Chef::Recipe::NetworkInterfaces.value(:metric,     new_resource.device, new_resource, node),
      mtu:          Chef::Recipe::NetworkInterfaces.value(:mtu,        new_resource.device, new_resource, node),
      up_down_cmd: up_down_cmd,
      custom:       Chef::Recipe::NetworkInterfaces.value(:custom, new_resource.device, new_resource, node),
      hotplug:      Chef::Recipe::NetworkInterfaces.value(:hotplug, new_resource.device, new_resource, node)
    )
    notifies :run, "execute[if_up #{new_resource.name}]", :immediately
  end
end

action :remove do
  execute "if_down #{new_resource.name}" do
    command "ifdown #{Chef::Recipe::NetworkInterfaces.value(:device, new_resource.device, new_resource, node)} -i /etc/network/interfaces.d/#{Chef::Recipe::NetworkInterfaces.value(:device, new_resource.device, new_resource, node)}"
    only_if "ifdown -n #{Chef::Recipe::NetworkInterfaces.value(:device, new_resource.device, new_resource, node)} -i /etc/network/interfaces.d/#{Chef::Recipe::NetworkInterfaces.value(:device, new_resource.device, new_resource, node)}"
    action :nothing
  end

  delete_lines "auto #{new_resource.device}" do
    path '/etc/network/interfaces.d/00interfaces'
    pattern "^auto #{new_resource.device}"
    action :nothing
  end

  file "/etc/network/interfaces.d/#{new_resource.filename}" do
    action :delete
    notifies :run, "execute[if_down #{new_resource.name}]", :immediately
    notifies :edit, "delete_lines[auto #{new_resource.device}]", :immediately
  end
end
