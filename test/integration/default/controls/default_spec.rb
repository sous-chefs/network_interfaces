# frozen_string_literal: true

control 'network-interfaces-base-01' do
  impact 1.0
  title 'Base interfaces files are managed'

  describe file('/etc/network/interfaces') do
    it { should exist }
    its('content') { should match(%r{source /etc/network/interfaces.d/\*}) }
  end

  describe directory('/etc/network/interfaces.d') do
    it { should exist }
    its('mode') { should cmp '0755' }
  end
end

control 'network-interfaces-resource-01' do
  impact 1.0
  title 'Interface resources render configuration'

  describe file('/etc/network/interfaces.d/lo') do
    it { should exist }
    its('content') { should match(/iface lo inet static/) }
    its('content') { should match(/address 127\.0\.0\.2/) }
  end

  describe file('/etc/network/interfaces.d/lo_ipv4') do
    it { should exist }
    its('content') { should match(/address 127\.0\.0\.3/) }
  end

  describe file('/etc/network/interfaces.d/lo_ipv4_2') do
    it { should exist }
    its('content') { should match(/address 172\.16\.88\.4/) }
  end
end
