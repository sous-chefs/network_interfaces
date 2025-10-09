default_action :save

property :device,     String, name_property: true
property :filename,   String, regex: /^\S*$/, name_property: true
property :family,     String, default: 'inet'
property :type,       String
property :bridge,     [TrueClass, FalseClass, Array]
property :bridge_stp, [true, false]
property :bond,       [TrueClass, FalseClass, Array]
property :bond_mode,  String
property :vlan_dev,   String
property :onboot,     [true, false], default: true
property :bootproto,  String
property :target,     String
property :gateway,    String
property :metric,     Integer
property :mtu,        Integer
property :mask,       String
property :network,    String
property :broadcast,  String
property :pre_up,     [String, Array]
property :up,         [String, Array]
property :post_up,    [String, Array]
property :pre_down,   [String, Array]
property :down,       [String, Array]
property :post_down,  [String, Array]
property :custom,     Hash
property :hotplug,    [true, false], default: false

action :save do
  node.normal['network_interfaces']['order'] = (node['network_interfaces']['order'] || []) + [new_resource.device]

  new_resource.bridge = ['none'] if new_resource.bridge && new_resource.bridge.class != Array

  if new_resource.vlan_dev || new_resource.device =~ /(en|eth|bond|wlan)[0-9]+\.[0-9]+/
    package 'vlan'
    modules '8021q'
  end

  new_resource.bond = ['none'] if new_resource.bond && new_resource.bond.class != Array

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
    command "ifdown #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device} ; " \
            "ifup #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device}"
    only_if "ifdown -n #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device} ; " \
            "ifup -n #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device}"
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
      device: new_resource.device,
      type: Chef::Recipe::NetworkInterfaces.value(:type,       new_resource.device, new_resource, node) || type,
      auto: Chef::Recipe::NetworkInterfaces.value(:onboot,     new_resource.device, new_resource, node),
      family: Chef::Recipe::NetworkInterfaces.value(:family, new_resource.device, new_resource, node),
      address: Chef::Recipe::NetworkInterfaces.value(:target,     new_resource.device, new_resource, node),
      network: Chef::Recipe::NetworkInterfaces.value(:network,    new_resource.device, new_resource, node),
      netmask: Chef::Recipe::NetworkInterfaces.value(:mask,       new_resource.device, new_resource, node),
      gateway: Chef::Recipe::NetworkInterfaces.value(:gateway,    new_resource.device, new_resource, node),
      broadcast: Chef::Recipe::NetworkInterfaces.value(:broadcast, new_resource.device, new_resource, node),
      bridge_ports: Chef::Recipe::NetworkInterfaces.value(:bridge, new_resource.device, new_resource, node),
      bridge_stp: Chef::Recipe::NetworkInterfaces.value(:bridge_stp, new_resource.device, new_resource, node),
      vlan_dev: Chef::Recipe::NetworkInterfaces.value(:vlan_dev, new_resource.device, new_resource, node),
      bond_slaves: Chef::Recipe::NetworkInterfaces.value(:bond, new_resource.device, new_resource, node),
      bond_mode: Chef::Recipe::NetworkInterfaces.value(:bond_mode, new_resource.device, new_resource, node),
      metric: Chef::Recipe::NetworkInterfaces.value(:metric, new_resource.device, new_resource, node),
      mtu: Chef::Recipe::NetworkInterfaces.value(:mtu, new_resource.device, new_resource, node),
      up_down_cmd: up_down_cmd,
      custom: Chef::Recipe::NetworkInterfaces.value(:custom, new_resource.device, new_resource, node),
      hotplug: Chef::Recipe::NetworkInterfaces.value(:hotplug, new_resource.device, new_resource, node)
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
