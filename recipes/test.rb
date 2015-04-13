include_recipe "network_interfaces::default"

network_interfaces 'eth1' do
  target [ "192.168.1.2", "192.168.1.3", "172.16.0.1/30", "fc00:dead:beef:cafe::1/64" ]
  mask "255.255.255.0"
  gateway "192.168.1.1"
  gateway6 "fc00:dead:beef:cafe::AA"
end

network_interfaces 'eth2' do
    mtu 9000
end

