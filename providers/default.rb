action :save do
  if new_resource.bridge and new_resource.bridge.class != Array
    new_resource.bridge = [ "none" ]
  end
  if new_resource.bootproto == "dhcp"
    type = "dhcp"
  elsif ! new_resource.target
    type = "manual"
  else
    type = "static"
  end

  if new_resource.metric
    package "ifmetric"
  end

  if new_resource.bridge_ports
    package "bridge-utils"
  end

  template "/etc/network/interfaces.d/#{device}" do
    source "interfaces.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :auto => new_resource.onboot,
      :type => type,
      :device => new_resource.device,
      :address => new_resource.target,
      :network => new_resource.network,
      :netmask => new_resource.mask,
      :bridge_ports => new_resource.bridge,
      :metric => new_resource.metric,
      :mtu => new_ressource.mtu,
      :pre_up => new_resource.pre_up,
      :up => new_resource.up,
      :down => new_resource.down,
      :post_down => new_resource.post_down,
      :custom => new_resource.custom
    )
    notifies :run, resources(:execute => "ifup")
  end

  execute "ifup" do
     command "ifup #{new_resource.device}"
     only_if "ifup -n #{new_resource.device}"
     action :nothing
  end
end

action :remove do
  file "/etc/network/interfaces.d/#{device}" do
    action :delete
  end

  execute "ifdown" do
    command "ifdown #{new_resource.device}"
    only_if "ifdown -n #{new_resource.device}"
  end
end
