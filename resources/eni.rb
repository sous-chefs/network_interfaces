# frozen_string_literal: true

require 'aws-sdk-ec2'
require 'net/http'
require 'uri'

provides :network_interfaces_eni
unified_mode true

default_action :create_and_attach

property :description, String
property :subnet_id, String
property :private_ip_address, String
property :security_groups, Array
property :network_interface_id, String
property :device_index, Integer
property :aws_region, String
property :aws_config, Hash, default: {}
property :metadata_endpoint, String, default: 'http://169.254.169.254/latest/'
property :metadata_token_ttl, Integer, default: 21_600
property :metadata_timeout, Integer, default: 2

action :create_and_attach do
  eni_id = new_resource.network_interface_id || create_network_interface
  return unless eni_id

  if attached_network_interface_ids.include?(eni_id)
    Chef::Log.debug("Network interface #{eni_id} is already attached to #{instance_id}")
  else
    converge_by("attach network interface #{eni_id} to #{instance_id} at index #{attachment_device_index}") do
      ec2_client.attach_network_interface(
        network_interface_id: eni_id,
        instance_id: instance_id,
        device_index: attachment_device_index
      )
    end
  end
end

action :create do
  create_network_interface
end

action :delete do
  eni = existing_network_interface

  if eni
    converge_by("delete network interface #{eni.network_interface_id}") do
      ec2_client.delete_network_interface(network_interface_id: eni.network_interface_id)
    end
  elsif new_resource.network_interface_id
    Chef::Log.debug("Network interface #{new_resource.network_interface_id} does not exist")
  else
    Chef::Log.debug("Network interface with description #{new_resource.description.inspect} does not exist")
  end
end

action_class do
  def create_network_interface
    eni = existing_network_interface
    return eni.network_interface_id if eni

    validate_create_options!

    converge_by("create network interface in subnet #{new_resource.subnet_id}") do
      @existing_network_interface = ec2_client.create_network_interface(create_options).network_interface
    end

    @existing_network_interface&.network_interface_id
  end

  def existing_network_interface
    return @existing_network_interface if defined?(@existing_network_interface)

    @existing_network_interface =
      if new_resource.network_interface_id
        describe_network_interface_by_id
      elsif new_resource.description
        describe_network_interface_by_description
      end
  end

  def ec2_client
    @ec2_client ||= Aws::EC2::Client.new(ec2_client_options)
  end

  def instance_id
    @instance_id ||= metadata_get('meta-data/instance-id')
  end

  def attachment_device_index
    @attachment_device_index ||= new_resource.device_index || next_device_index
  end

  def next_device_index
    device_numbers = metadata_macs.map do |mac|
      metadata_get("meta-data/network/interfaces/macs/#{mac}/device-number").to_i
    end

    device_numbers.max + 1
  end

  def metadata_macs
    @metadata_macs ||= metadata_get('meta-data/network/interfaces/macs/')
                       .lines
                       .map { |mac| mac.delete_suffix("/\n").delete_suffix('/') }
  end

  def attached_network_interface_ids
    @attached_network_interface_ids ||= metadata_macs.map do |mac|
      metadata_get("meta-data/network/interfaces/macs/#{mac}/interface-id")
    end
  end

  def metadata_get(path)
    uri = URI.join(new_resource.metadata_endpoint, path)
    request = Net::HTTP::Get.new(uri)
    request['X-aws-ec2-metadata-token'] = metadata_token if metadata_token

    http_response(uri, request).body
  end

  def metadata_token
    return @metadata_token if defined?(@metadata_token)

    uri = URI.join(new_resource.metadata_endpoint, 'api/token')
    request = Net::HTTP::Put.new(uri)
    request['X-aws-ec2-metadata-token-ttl-seconds'] = new_resource.metadata_token_ttl.to_s

    @metadata_token = http_response(uri, request).body
  rescue Net::HTTPError, SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Timeout::Error
    @metadata_token = nil
  end

  def http_response(uri, request)
    Net::HTTP.start(
      uri.hostname,
      uri.port,
      use_ssl: uri.scheme == 'https',
      open_timeout: new_resource.metadata_timeout,
      read_timeout: new_resource.metadata_timeout
    ) do |http|
      response = http.request(request)
      response.value
      response
    end
  end

  def describe_network_interface_by_id
    ec2_client.describe_network_interfaces(network_interface_ids: [new_resource.network_interface_id]).network_interfaces.first
  rescue Aws::EC2::Errors::InvalidNetworkInterfaceIDNotFound
    nil
  end

  def describe_network_interface_by_description
    results = ec2_client.describe_network_interfaces(
      filters: [
        {
          name: 'description',
          values: [new_resource.description],
        },
      ]
    ).network_interfaces

    raise Chef::Exceptions::ValidationFailed, "More than one network interface matches #{new_resource.description.inspect}: #{results.map(&:network_interface_id).join(', ')}" if results.count > 1

    results.first
  end

  def validate_create_options!
    raise Chef::Exceptions::ValidationFailed, 'subnet_id is required when creating a network interface' unless new_resource.subnet_id
    raise Chef::Exceptions::ValidationFailed, 'description is required to create a network interface idempotently' unless new_resource.description
  end

  def create_options
    {
      subnet_id: new_resource.subnet_id,
      description: new_resource.description,
    }.tap do |options|
      options[:private_ip_address] = new_resource.private_ip_address if new_resource.private_ip_address
      options[:groups] = new_resource.security_groups if new_resource.security_groups
    end
  end

  def ec2_client_options
    new_resource.aws_config.merge(
      new_resource.aws_region ? { region: new_resource.aws_region } : {}
    )
  end
end
