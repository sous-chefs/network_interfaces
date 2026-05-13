# frozen_string_literal: true

require 'spec_helper'

describe 'network_interfaces_eni' do
  step_into :network_interfaces_eni
  platform 'debian', '12'

  let(:ec2_client) { instance_double(Aws::EC2::Client) }
  let(:created_interface) { Aws::EC2::Types::NetworkInterface.new(network_interface_id: 'eni-created') }
  let(:create_response) { Aws::EC2::Types::CreateNetworkInterfaceResult.new(network_interface: created_interface) }
  let(:metadata_response) do
    Struct.new(:body) do
      def value; end
    end
  end
  let(:attached_network_interface_ids) { [] }

  before do
    allow(Aws::EC2::Client).to receive(:new).and_return(ec2_client)
    allow(Net::HTTP).to receive(:start) do |_host, _port, _options, &block|
      http = instance_double(Net::HTTP)

      allow(http).to receive(:request) do |request|
        body =
          case request
          when Net::HTTP::Put
            'metadata-token'
          else
            metadata_body(request.path)
          end

        metadata_response.new(body)
      end

      block.call(http)
    end

    allow(ec2_client).to receive(:attach_network_interface)
  end

  def metadata_body(path)
    metadata_path = path.delete_prefix('/latest/')

    case metadata_path
    when 'meta-data/instance-id'
      'i-1234567890abcdef0'
    when 'meta-data/network/interfaces/macs/'
      "02:00:00:00:00:00/\n"
    when 'meta-data/network/interfaces/macs/02:00:00:00:00:00/device-number'
      '0'
    when 'meta-data/network/interfaces/macs/02:00:00:00:00:00/interface-id'
      attached_network_interface_ids.first.to_s
    end
  end

  context 'when creating and attaching a new network interface' do
    recipe do
      network_interfaces_eni 'app-secondary-interface' do
        description 'app-secondary-interface'
        subnet_id 'subnet-1234567890abcdef0'
        private_ip_address '192.0.2.10'
        security_groups ['sg-1234567890abcdef0']
        aws_region 'eu-west-2'
        device_index 1
      end
    end

    before do
      allow(ec2_client).to receive(:describe_network_interfaces).and_return(
        Aws::EC2::Types::DescribeNetworkInterfacesResult.new(network_interfaces: [])
      )
      allow(ec2_client).to receive(:create_network_interface).and_return(create_response)
    end

    it 'creates the interface with EC2 API options' do
      chef_run

      expect(ec2_client).to have_received(:create_network_interface).with(
        subnet_id: 'subnet-1234567890abcdef0',
        description: 'app-secondary-interface',
        private_ip_address: '192.0.2.10',
        groups: ['sg-1234567890abcdef0']
      )
    end

    it 'attaches the created interface to the instance' do
      chef_run

      expect(ec2_client).to have_received(:attach_network_interface).with(
        network_interface_id: 'eni-created',
        instance_id: 'i-1234567890abcdef0',
        device_index: 1
      )
    end
  end

  context 'when attaching an existing network interface that is already attached' do
    let(:attached_network_interface_ids) { ['eni-existing'] }

    recipe do
      network_interfaces_eni 'existing-interface' do
        network_interface_id 'eni-existing'
      end
    end

    it 'does not attach the interface again' do
      chef_run

      expect(ec2_client).not_to have_received(:attach_network_interface)
    end
  end

  context 'when deleting a network interface by id' do
    let(:existing_interface) { Aws::EC2::Types::NetworkInterface.new(network_interface_id: 'eni-existing') }

    recipe do
      network_interfaces_eni 'existing-interface' do
        network_interface_id 'eni-existing'
        action :delete
      end
    end

    before do
      allow(ec2_client).to receive(:describe_network_interfaces).and_return(
        Aws::EC2::Types::DescribeNetworkInterfacesResult.new(network_interfaces: [existing_interface])
      )
      allow(ec2_client).to receive(:delete_network_interface)
    end

    it 'deletes the interface' do
      chef_run

      expect(ec2_client).to have_received(:delete_network_interface).with(network_interface_id: 'eni-existing')
    end
  end
end
