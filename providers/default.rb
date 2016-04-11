action :save do
  node.set['network_interfaces']['order'] =
    (node['network_interfaces']['order'] || []) + [new_resource.device]

  if new_resource.bridge && ! new_resource.bridge.kind_of?(Array)
    new_resource.bridge = ['none']
  end

  if new_resource.vlan_dev ||
    new_resource.device =~ /(eth|bond|wlan)[0-9]+\.[0-9]+/
    package 'vlan'
    modules '8021q'
  end

  if new_resource.bond && ! new_resource.bond.kind_of?(Array)
    new_resource.bond = ['none']
  end

  if new_resource.bond
    package 'ifenslave-2.6'
    modules 'bonding'
    new_resource.bond.each do |bond_slave|
      `ip address flush dev #{bond_slave}`
      `dhclient -r -pf /run/dhclient.#{bond_slave}.pid && rm -f /run/dhclient.#{bond_slave}.pid` if ::File.exist?("/run/dhclient.#{bond_slave}.pid")
    end
  end

  if new_resource.bootproto == 'dhcp'
    method = 'dhcp'
  else
    method = new_resource.method
  end

  package 'ifmetric' if Chef::Recipe::NetworkInterfaces.value(:metric, new_resource.device, new_resource, node)

  package 'bridge-utils' if new_resource.bridge

  if_up = execute "if_up #{new_resource.device}" do
    command "ifup #{new_resource.device}  -i /etc/network/interfaces.d/#{new_resource.device}"
    only_if "ifup -n #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device}"
    action :nothing
  end

  if_down = execute "if_down #{new_resource.device}" do
    command "ifdown #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device}"
    only_if "ifdown -n #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device}"
    action :nothing
  end


  dhclient_stop = execute "dhclient stop on #{new_resource.device}" do
    command "dhclient -r -pf /run/dhclient.#{new_resource.device}.pid && rm -f /run/dhclient.#{new_resource.device}.pid"
    only_if { ::File.exist?("/run/dhclient.#{new_resource.device}.pid") }
    action :nothing
  end

  address_flush = execute "flushing address on #{new_resource.device}" do
    command "ip address flush dev #{new_resource.device}"
    ignore_failure true
    action :nothing
    not_if { /:/.match("#{new_resource.device}")}
  end

  cmp = ruby_block "compare config and template #{new_resource.device}" do
    block do
      require 'fileutils'
      FileUtils.touch "/etc/network/interfaces.d/#{new_resource.device}"
      unless FileUtils.compare_file("/var/chef/templates/interfaces/#{new_resource.device}.erb", "/etc/network/interfaces.d/#{new_resource.device}")
        notifies :run, resources(:execute => "if_down #{new_resource.device}"), :immediately
        notifies :run, resources(:execute => "flushing address on #{new_resource.device}"), :immediately
      end
    end
    action :nothing
  end

  template "/var/chef/templates/interfaces/#{new_resource.device}.erb" do
    cookbook "network_interfaces"
    source 'interfaces.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      auto:         Chef::Recipe::NetworkInterfaces.value(:onboot,     new_resource.device, new_resource, node),
      method:       method,
      device:       new_resource.device,
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
      pre_up:       Chef::Recipe::NetworkInterfaces.value(:pre_up,     new_resource.device, new_resource, node),
      up:           Chef::Recipe::NetworkInterfaces.value(:up,         new_resource.device, new_resource, node),
      post_up:      Chef::Recipe::NetworkInterfaces.value(:post_up,    new_resource.device, new_resource, node),
      pre_down:     Chef::Recipe::NetworkInterfaces.value(:pre_down,   new_resource.device, new_resource, node),
      down:         Chef::Recipe::NetworkInterfaces.value(:down,       new_resource.device, new_resource, node),
      post_down:    Chef::Recipe::NetworkInterfaces.value(:post_down,  new_resource.device, new_resource, node),
      custom:       Chef::Recipe::NetworkInterfaces.value(:custom,     new_resource.device, new_resource, node)
    )
    notifies :create, "ruby_block[compare config and template #{new_resource.device}]", :immediately
    notifies :run, "execute[dhclient stop on #{new_resource.device}]", :immediately
  end

  template "/etc/network/interfaces.d/#{new_resource.device}" do
    local true
    source "/var/chef/templates/interfaces/#{new_resource.device}.erb"
    owner 'root'
    group 'root'
    mode '0644'
    notifies :run, "execute[if_up #{new_resource.device}]", :immediately
    notifies :create, 'ruby_block[Merge interfaces]', :delayed
  end

  new_resource.updated_by_last_action(if_up.updated_by_last_action?)
end

action :remove do
  if_down = execute "if_down #{new_resource.device}" do
    command "ifdown #{Chef::Recipe::NetworkInterfaces.value(:device, new_resource.device, new_resource, node)} -i /etc/network/interfaces.d/#{Chef::Recipe::NetworkInterfaces.value(:device, new_resource.device, new_resource, node)}"
    only_if "ifdown -n #{Chef::Recipe::NetworkInterfaces.value(:device, new_resource.device, new_resource, node)} -i /etc/network/interfaces.d/#{Chef::Recipe::NetworkInterfaces.value(:device, new_resource.device, new_resource, node)}"
  end

  file "/etc/network/interfaces.d/#{new_resource.device}" do
    action :delete
    notifies :run, "execute[if_down #{new_resource.device}]", :immediately
    notifies :create, 'ruby_block[Merge interfaces]', :delayed
  end

  new_resource.updated_by_last_action(if_down.updated_by_last_action?)
end
