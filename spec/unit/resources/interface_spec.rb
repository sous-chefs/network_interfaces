# frozen_string_literal: true

require 'spec_helper'

describe 'network_interfaces' do
  step_into :network_interfaces
  platform 'debian', '12'

  context 'with a static interface' do
    recipe do
      network_interfaces 'eth1' do
        target '192.0.2.10'
        mask '255.255.255.0'
        gateway '192.0.2.1'
        reload_interface false
      end
    end

    it { is_expected.to edit_append_if_no_line('insert auto for eth1') }
    it { is_expected.to create_template('/etc/network/interfaces.d/eth1') }
    it { is_expected.to render_file('/etc/network/interfaces.d/eth1').with_content(/iface eth1 inet static/) }
    it { is_expected.to render_file('/etc/network/interfaces.d/eth1').with_content(/address 192\.0\.2\.10/) }
    it { is_expected.to render_file('/etc/network/interfaces.d/eth1').with_content(/gateway 192\.0\.2\.1/) }
  end

  context 'with vlan and bridge properties' do
    recipe do
      network_interfaces 'eth1.100' do
        vlan_dev 'eth1'
        bridge true
        metric 100
        reload_interface false
      end
    end

    it { is_expected.to install_package('vlan') }
    it { is_expected.to install_package('ifmetric') }
    it { is_expected.to install_package('bridge-utils') }
    it { is_expected.to render_file('/etc/network/interfaces.d/eth1.100').with_content(/bridge_ports none/) }
    it { is_expected.to render_file('/etc/network/interfaces.d/eth1.100').with_content(/metric 100/) }
  end

  context 'when removing an interface' do
    recipe do
      network_interfaces 'eth1' do
        reload_interface false
        action :remove
      end
    end

    it { is_expected.to delete_file('/etc/network/interfaces.d/eth1') }
    it { is_expected.to nothing_execute('if_down eth1') }
    it { is_expected.to nothing_delete_lines('auto eth1') }
  end
end
