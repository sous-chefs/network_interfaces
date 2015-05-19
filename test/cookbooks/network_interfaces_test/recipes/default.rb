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
