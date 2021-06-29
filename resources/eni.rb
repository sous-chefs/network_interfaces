require 'aws-sdk'
require 'net/http'

default_action :create_and_attach

property :description,          String
property :subnet_id,            String, required: true
property :private_ip_address,   String
property :security_groups,      Array
property :network_interface_id, String

action :create_and_attach do
  nic_id_to_attach = network_interface_id || create

  if attached_nic_ids.include? nic_id_to_attach
    Chef::Log.debug "NIC with ID #{nic_id_to_attach} is already attached to #{instance_id}"
  else
    converge_by "Attach NIC #{nic_id_to_attach} to #{instance_id} at index #{next_device_index}" do
      ec2.attach_network_interface(
        network_interface_id: nic_id_to_attach,
        instance_id: instance_id,
        device_index: next_device_index
      )
    end
  end
end

action :create do
  create
end

action :delete do
  if existing_nic
    converge_by "Delete the NIC with ID #{existing_nic.network_interface_id}" do
      ec2.delete_network_interface network_interface_id: existing_nic.network_interface_id
    end
  elsif network_interface_id
    Chef::Log.debug "NIC with ID #{network_interface_id} does not exist"
  else
    Chef::Log.debug "NIC with description \"#{description}\" does not exist"
  end
end

private

def create
  if existing_nic_id
    Chef::Log.debug("NIC already exists: #{existing_nic.network_interface_id}/#{description}")
    return existing_nic.network_interface_id
  end

  converge_by "Create new NIC in description: #{description}, subnet_id: #{subnet_id}" do
    options = {}

    %w(subnet_id private_ip_address security_groups).each do |prop|
      next unless send prop
      options[prop.to_sym] = send(prop)
    end

    ec2.create_network_interface(options).network_interface.network_interface_id
  end
end

def existing_nic
  @existing_nic ||= begin
    # Use the ID to look up the adapter if we have it
    return ec2.describe_network_interfaces(
      network_interface_id: network_interface_id
    ).network_interfaces.first if network_interface_id

    # Otherwise use the description
    results = ec2.describe_network_interfaces(
      filters: [{ name: 'description', values: [description] }]
    ).network_interfaces

    # Multiple NICs with the same description == problems
    if results.count > 1
      fail "More than one NIC matches the description \"#{description}\": " \
           "#{results.map(&:network_interface_id).join ', '}"
    end

    results.first
  end
end

def ec2
  @ec2 ||= AWS::EC2::Client.new
end

def instance_id
  @instance_id ||= Net::HTTP.get URI 'http://169.254.169.254/2016-09-02/meta-data/instance-id'
end

def next_device_index
  @next_device_index ||= begin
    device_numbers = macs.map do |mac|
      Net::HTTP.get(
        URI "http://169.254.169.254/2016-09-02/meta-data/network/interfaces/macs/#{mac}/device-number"
      ).to_i
    end

    device_numbers.sort.last + 1
  end
end

def macs
  @macs ||= Net::HTTP.get(
    URI 'http://169.254.169.254/2016-09-02/meta-data/network/interfaces/macs/'
  ).delete('/').split("\n")
end

def attached_nic_ids
  @attached_nic_ids ||= begin
    macs.map do |mac|
      Net::HTTP.get(
        URI "http://169.254.169.254/2016-09-02/meta-data/network/interfaces/macs/#{mac}" \
            '/interface-id'
      )
    end
  end
end
