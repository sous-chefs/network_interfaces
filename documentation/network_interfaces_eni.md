# network_interfaces_eni

Creates, attaches, and deletes AWS Elastic Network Interfaces (ENIs) for EC2 instances.

This resource was originally contributed by [@eherot](https://github.com/eherot) and submitted to this cookbook by [@jeffbyrnes](https://github.com/jeffbyrnes) in [#32](https://github.com/sous-chefs/network_interfaces/pull/32).

## Actions

* `:create_and_attach` - Creates a matching ENI when needed and attaches it to the current EC2 instance. Default.
* `:create` - Creates a matching ENI when needed.
* `:delete` - Deletes a matching ENI.

## Properties

* `description` - String. ENI description used to find the interface idempotently.
* `subnet_id` - String. Subnet for newly created ENIs.
* `private_ip_address` - String. Optional primary private IP address.
* `security_groups` - Array. Security group IDs for the ENI.
* `network_interface_id` - String. Existing ENI ID to attach or delete.
* `device_index` - Integer. Attachment device index. Defaults to the next index from EC2 instance metadata.
* `aws_region` - String. AWS region passed to the EC2 client.
* `aws_config` - Hash, default `{}`. Additional options passed to `Aws::EC2::Client`.
* `metadata_endpoint` - String, default `'http://169.254.169.254/latest/'`. EC2 metadata endpoint.
* `metadata_token_ttl` - Integer, default `21600`. IMDSv2 token TTL in seconds.
* `metadata_timeout` - Integer, default `2`. EC2 metadata HTTP timeout in seconds.

## Examples

### Create and attach an ENI

```ruby
network_interfaces_eni 'app-secondary-interface' do
  description 'app-secondary-interface'
  subnet_id 'subnet-1234567890abcdef0'
  security_groups ['sg-1234567890abcdef0']
  aws_region 'eu-west-2'
end
```

### Attach an existing ENI at a fixed index

```ruby
network_interfaces_eni 'eni-attach' do
  network_interface_id 'eni-1234567890abcdef0'
  device_index 1
  aws_region 'eu-west-2'
end
```
