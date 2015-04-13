network_interfaces 'lo' do
  target '127.0.0.2'
  mask '255.255.255.0'
end

network_interfaces 'lo_ipv4' do
  device 'lo'
  target '127.0.0.3'
  mask '255.255.255.0'
end

network_interfaces 'my interface' do
  device 'lo'
  filename 'lo_ipv4_2'
  target '172.16.88.4'
  mask '255.255.255.0'
end

network_interfaces 'eth1' do
  target ['192.168.1.2', '192.168.1.3', '172.16.0.1/30', 'fc00:dead:beef:cafe::1/64']
  mask '255.255.255.0'
  gateway '192.168.1.1'
  gateway6 'fc00:dead:beef:cafe::AA'
end

network_interfaces 'eth2' do
  mtu 9000
end
