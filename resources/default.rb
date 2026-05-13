# frozen_string_literal: true

provides :network_interfaces
unified_mode true

default_action :save

property :device, String, name_property: true
property :filename, String, default: lazy { name }, callbacks: { 'cannot include whitespace' => ->(value) { value.match?(/^\S*$/) } }
property :family, String, default: 'inet'
property :type, String
property :bridge, [TrueClass, FalseClass, Array]
property :bridge_stp, [true, false]
property :bond, [TrueClass, FalseClass, Array]
property :bond_mode, String
property :vlan_dev, String
property :onboot, [true, false], default: true
property :bootproto, String
property :target, String
property :gateway, String
property :metric, Integer
property :mtu, Integer
property :mask, String
property :network, String
property :broadcast, String
property :pre_up, [String, Array]
property :up, [String, Array]
property :post_up, [String, Array]
property :pre_down, [String, Array]
property :down, [String, Array]
property :post_down, [String, Array]
property :custom, Hash
property :hotplug, [true, false], default: false
property :reload_interface, [true, false], default: true

action :save do
  node.run_state['network_interfaces_order'] ||= []
  node.run_state['network_interfaces_order'] << new_resource.device

  if new_resource.vlan_dev || new_resource.device =~ /(en|eth|bond|wlan)[0-9]+\.[0-9]+/
    package 'vlan'
    modules '8021q'
  end

  if new_resource.bond
    package 'ifenslave-2.6'
    modules 'bonding'
  end

  package 'ifmetric' if new_resource.metric
  package 'bridge-utils' if new_resource.bridge

  execute "if_up #{new_resource.name}" do
    command "ifdown #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device} ; " \
            "ifup #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device}"
    only_if "ifdown -n #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device} ; " \
            "ifup -n #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device}"
    only_if { new_resource.reload_interface }
    action :nothing
  end

  append_if_no_line "insert auto for #{new_resource.device}" do
    line "auto #{new_resource.device}"
    path '/etc/network/interfaces.d/00interfaces'
    only_if { new_resource.onboot }
  end

  template "/etc/network/interfaces.d/#{new_resource.filename}" do
    cookbook 'network_interfaces'
    source 'interfaces.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      device: new_resource.device,
      type: interface_type,
      auto: new_resource.onboot,
      family: new_resource.family,
      address: new_resource.target,
      network: new_resource.network,
      netmask: new_resource.mask,
      gateway: new_resource.gateway,
      broadcast: new_resource.broadcast,
      bridge_ports: normalized_option(new_resource.bridge),
      bridge_stp: new_resource.bridge_stp,
      vlan_dev: new_resource.vlan_dev,
      bond_slaves: normalized_option(new_resource.bond),
      bond_mode: new_resource.bond_mode,
      metric: new_resource.metric,
      mtu: new_resource.mtu,
      up_down_cmd: up_down_commands,
      custom: new_resource.custom,
      hotplug: new_resource.hotplug
    )
    notifies :run, "execute[if_up #{new_resource.name}]", :immediately
  end
end

action :remove do
  execute "if_down #{new_resource.name}" do
    command "ifdown #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device}"
    only_if "ifdown -n #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device}"
    only_if { new_resource.reload_interface }
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

action_class do
  include NetworkInterfacesCookbook::Helpers
end
