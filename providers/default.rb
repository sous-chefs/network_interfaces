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
    target = new_resource.target
    target = [ new_resource.target ] if new_resource.target.class != Array 
  end

  package 'ifmetric' if Chef::Recipe::NetworkInterfaces.value(:metric, new_resource.device, new_resource, node)

  package 'bridge-utils' if new_resource.bridge

  if_up = execute "if_up #{new_resource.name}" do
    command "ifdown #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device} ; ifup #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device}"
    only_if "ifdown -n #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device} ; ifup -n #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device}"
    action :nothing
  end

  e = []
  seen_v4=false
  seen_v6=false
  target.each_with_index do |t, i|
    if t.include? '/'
	#Addres includes netmask in a CIDR format
	netmask = t.split('/')[1]
        t = t.split('/')[0]
    else
        netmask = Chef::Recipe::NetworkInterfaces.value(:mask,       new_resource.device, new_resource, node)
    end

    if t.include? ':'
	#IPv6
	family = 'inet6'
    else
	#IPv4
        family = 'inet'
	if !netmask.include? '.'
    	  #Netmask specified in a CIDR format
    	  netmask = IPAddr.new('255.255.255.255').mask(netmask).to_s
	end
    end

    iface_data = {
        "type" =>         type,
        "family" =>       family,
        "device" =>       new_resource.device,
        "address" =>      t,
        "netmask" =>      netmask
    }

    if !seen_v6 and family=='inet6'
        iface_data["gateway"] = Chef::Recipe::NetworkInterfaces.value(:gateway6,    new_resource.device, new_resource, node)
        seen_v6=true
    end
    if !seen_v4 and family=='inet'
        iface_data["gateway"] = Chef::Recipe::NetworkInterfaces.value(:gateway,    new_resource.device, new_resource, node)
        seen_v4=true
    end

    if i ==0 
	#We need the whole interface description only at the first address entry
	iface_data["auto"]=Chef::Recipe::NetworkInterfaces.value(:onboot,     new_resource.device, new_resource, node)
        iface_data["network"] =      Chef::Recipe::NetworkInterfaces.value(:network,    new_resource.device, new_resource, node),
        iface_data["broadcast"] =    Chef::Recipe::NetworkInterfaces.value(:broadcast,  new_resource.device, new_resource, node),
        iface_data["bridge_ports"] = Chef::Recipe::NetworkInterfaces.value(:bridge,     new_resource.device, new_resource, node),
        iface_data["bridge_stp"] =   Chef::Recipe::NetworkInterfaces.value(:bridge_stp, new_resource.device, new_resource, node),
        iface_data["vlan_dev"] =     Chef::Recipe::NetworkInterfaces.value(:vlan_dev,   new_resource.device, new_resource, node),
        iface_data["bond_slaves"] =  Chef::Recipe::NetworkInterfaces.value(:bond,       new_resource.device, new_resource, node),
        iface_data["bond_mode"] =    Chef::Recipe::NetworkInterfaces.value(:bond_mode,  new_resource.device, new_resource, node),
        iface_data["metric"] =       Chef::Recipe::NetworkInterfaces.value(:metric,     new_resource.device, new_resource, node),
        iface_data["mtu"] =          Chef::Recipe::NetworkInterfaces.value(:mtu,        new_resource.device, new_resource, node),
        iface_data["pre_up"] =       Chef::Recipe::NetworkInterfaces.value(:pre_up,     new_resource.device, new_resource, node),
        iface_data["up"] =           Chef::Recipe::NetworkInterfaces.value(:up,         new_resource.device, new_resource, node),
        iface_data["post_up"] =      Chef::Recipe::NetworkInterfaces.value(:post_up,    new_resource.device, new_resource, node),
        iface_data["pre_down"] =     Chef::Recipe::NetworkInterfaces.value(:pre_down,   new_resource.device, new_resource, node),
        iface_data["down"] =        Chef::Recipe::NetworkInterfaces.value(:down,       new_resource.device, new_resource, node),
        iface_data["post_down"] =    Chef::Recipe::NetworkInterfaces.value(:post_down,  new_resource.device, new_resource, node),
        iface_data["custom"] =       Chef::Recipe::NetworkInterfaces.value(:custom,     new_resource.device, new_resource, node)
    end 
    e.push(iface_data)
  end 

  template "/etc/network/interfaces.d/#{new_resource.device}" do
    cookbook 'network_interfaces'
    source 'interfaces.erb'
    owner 'root'
    group 'root' 
    mode '0644'
    variables( :entries => e )
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
