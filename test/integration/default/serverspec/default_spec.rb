require 'spec_helper'

describe 'network_interfaces::test' do
  describe file('/etc/network/interfaces') do
    it { should contain 'source /etc/network/interfaces.d/*' }
  end

  describe interface('eth1') do
    it { should exist }
    it { should have_ipv4_address('192.168.1.2/24') }
    it { should have_ipv4_address('172.16.0.1/30') }
    it { should have_ipv4_address('192.168.1.3/24') }
  end
end
