action :save do

  node.set['network_interfaces']['order'] = (node['network_interfaces']['order'] || []) + [new_resource.device]

  new_resource.bridge = ['none'] if new_resource.bridge && new_resource.bridge.class != Array

  if new_resource.vlan_dev || new_resource.device =~ /(eth|bond|wlan)[0-9]+\.[0-9]+/
    package 'vlan'
    modules '8021q'
  end

  new_resource.bond = ['none'] if new_resource.bond && new_resource.bond.class != Array

  if new_resource.bond
    package 'ifenslave-2.6'
    modules 'bonding'
  end

  if new_resource.bootproto == 'dhcp'
    type = 'dhcp'
  elsif !new_resource.target
    type = 'manual'
  else
    type = 'static'
  end

  package 'ifmetric' if Chef::Recipe::Network_interfaces.value(:metric, new_resource.device, new_resource, node)

  package 'bridge-utils' if new_resource.bridge

  execute "if_up #{new_resource.name}" do
    command "ifdown #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device} ; ifup #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device}"
    only_if "ifdown -n #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device} ; ifup -n #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device}"
    action :nothing
  end

  template "/etc/network/interfaces.d/#{new_resource.device}" do
    cookbook 'network_interfaces'
    source 'interfaces.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      auto:         Chef::Recipe::Network_interfaces.value(:onboot,     new_resource.device, new_resource, node),
      type:         type,
      device:       new_resource.device,
      address:      Chef::Recipe::Network_interfaces.value(:target,     new_resource.device, new_resource, node),
      network:      Chef::Recipe::Network_interfaces.value(:network,    new_resource.device, new_resource, node),
      netmask:      Chef::Recipe::Network_interfaces.value(:mask,       new_resource.device, new_resource, node),
      gateway:      Chef::Recipe::Network_interfaces.value(:gateway,    new_resource.device, new_resource, node),
      broadcast:    Chef::Recipe::Network_interfaces.value(:broadcast,  new_resource.device, new_resource, node),
      bridge_ports: Chef::Recipe::Network_interfaces.value(:bridge,     new_resource.device, new_resource, node),
      bridge_stp:   Chef::Recipe::Network_interfaces.value(:bridge_stp, new_resource.device, new_resource, node),
      vlan_dev:     Chef::Recipe::Network_interfaces.value(:vlan_dev,   new_resource.device, new_resource, node),
      bond_slaves:  Chef::Recipe::Network_interfaces.value(:bond,       new_resource.device, new_resource, node),
      bond_mode:    Chef::Recipe::Network_interfaces.value(:bond_mode,  new_resource.device, new_resource, node),
      metric:       Chef::Recipe::Network_interfaces.value(:metric,     new_resource.device, new_resource, node),
      mtu:          Chef::Recipe::Network_interfaces.value(:mtu,        new_resource.device, new_resource, node),
      pre_up:       Chef::Recipe::Network_interfaces.value(:pre_up,     new_resource.device, new_resource, node),
      up:           Chef::Recipe::Network_interfaces.value(:up,         new_resource.device, new_resource, node),
      post_up:      Chef::Recipe::Network_interfaces.value(:post_up,    new_resource.device, new_resource, node),
      pre_down:     Chef::Recipe::Network_interfaces.value(:pre_down,   new_resource.device, new_resource, node),
      down:         Chef::Recipe::Network_interfaces.value(:down,       new_resource.device, new_resource, node),
      post_down:    Chef::Recipe::Network_interfaces.value(:post_down,  new_resource.device, new_resource, node),
      custom:       Chef::Recipe::Network_interfaces.value(:custom,     new_resource.device, new_resource, node)
    )
    notifies :run, "execute[if_up #{new_resource.name}]", :immediately
    notifies :create, 'ruby_block[Merge interfaces]', :delayed
  end
end

action :remove do
  execute "if_down #{new_resource.name}" do
    command "ifdown #{Chef::Recipe::Network_interfaces.value(:device, new_resource.device, new_resource, node)} -i /etc/network/interfaces.d/#{Chef::Recipe::Network_interfaces.value(:device, new_resource.device, new_resource, node)}"
    only_if "ifdown -n #{Chef::Recipe::Network_interfaces.value(:device, new_resource.device, new_resource, node)} -i /etc/network/interfaces.d/#{Chef::Recipe::Network_interfaces.value(:device, new_resource.device, new_resource, node)}"
  end

  file "/etc/network/interfaces.d/#{new_resource.device}" do
    action :delete
    notifies :run, "execute[if_down #{new_resource.name}]", :immediately
    notifies :create, 'ruby_block[Merge interfaces]', :delayed
  end
end
