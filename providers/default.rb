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

  package 'ifmetric' if Chef::Recipe::NetworkInterfaces.value(:metric, new_resource.device, new_resource, node)

  package 'bridge-utils' if new_resource.bridge

  if_up = execute "if_up #{new_resource.name}" do
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
      auto:         Chef::Recipe::NetworkInterfaces.value(:onboot,     new_resource.device, new_resource, node),
      type:         type,
      device:       new_resource.device,
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
      pre_up:       Chef::Recipe::NetworkInterfaces.value(:pre_up,     new_resource.device, new_resource, node),
      up:           Chef::Recipe::NetworkInterfaces.value(:up,         new_resource.device, new_resource, node),
      post_up:      Chef::Recipe::NetworkInterfaces.value(:post_up,    new_resource.device, new_resource, node),
      pre_down:     Chef::Recipe::NetworkInterfaces.value(:pre_down,   new_resource.device, new_resource, node),
      down:         Chef::Recipe::NetworkInterfaces.value(:down,       new_resource.device, new_resource, node),
      post_down:    Chef::Recipe::NetworkInterfaces.value(:post_down,  new_resource.device, new_resource, node),
      custom:       Chef::Recipe::NetworkInterfaces.value(:custom,     new_resource.device, new_resource, node)
    )
    notifies :run, "execute[if_up #{new_resource.name}]", :immediately
    notifies :create, 'ruby_block[Merge interfaces]', :delayed
  end

  new_resource.updated_by_last_action(if_up.updated_by_last_action?)
end

action :remove do
  if_down = execute "if_down #{new_resource.name}" do
    command "ifdown #{Chef::Recipe::NetworkInterfaces.value(:device, new_resource.device, new_resource, node)} -i /etc/network/interfaces.d/#{Chef::Recipe::NetworkInterfaces.value(:device, new_resource.device, new_resource, node)}"
    only_if "ifdown -n #{Chef::Recipe::NetworkInterfaces.value(:device, new_resource.device, new_resource, node)} -i /etc/network/interfaces.d/#{Chef::Recipe::NetworkInterfaces.value(:device, new_resource.device, new_resource, node)}"
  end

  file "/etc/network/interfaces.d/#{new_resource.device}" do
    action :delete
    notifies :run, "execute[if_down #{new_resource.name}]", :immediately
    notifies :create, 'ruby_block[Merge interfaces]', :delayed
  end

  new_resource.updated_by_last_action(if_down.updated_by_last_action?)
end
