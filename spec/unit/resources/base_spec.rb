# frozen_string_literal: true

require 'spec_helper'

describe 'network_interfaces_base' do
  step_into :network_interfaces_base
  platform 'debian', '12'

  context 'with default properties' do
    recipe do
      network_interfaces_base 'default'
    end

    it { is_expected.to create_directory('/etc/network').with(owner: 'root', group: 'root', mode: '0755') }
    it { is_expected.to create_file('/etc/network/interfaces') }
    it { is_expected.to create_directory('/etc/network/interfaces.d').with(owner: 'root', group: 'root', mode: '0755') }
  end

  context 'when replacing the original file' do
    recipe do
      network_interfaces_base 'default' do
        replace_orig true
      end
    end

    it { is_expected.to create_file('/etc/network/interfaces').with_content(%r{source /etc/network/interfaces.d/\*}) }
  end

  context 'when deleting' do
    recipe do
      network_interfaces_base 'default' do
        action :delete
      end
    end

    it { is_expected.to edit_delete_lines('remove source /etc/network/interfaces.d/*') }
    it { is_expected.to delete_directory('/etc/network/interfaces.d') }
  end
end
