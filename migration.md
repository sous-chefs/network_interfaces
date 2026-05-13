# Migration

## From Recipes and Attributes

This release removes the legacy public recipe and attribute API.

Removed APIs:

* `recipe[network_interfaces]`
* `node['network_interfaces']['replace_orig']`
* `node['network_interfaces']['interface']` fallback values read by the resource

Use custom resources directly instead.

### Before

```ruby
node.default['network_interfaces']['replace_orig'] = true

include_recipe 'network_interfaces'

network_interfaces 'br-test' do
  target '172.16.88.2'
  mask '255.255.255.0'
  bridge ['none']
end
```

### After

```ruby
network_interfaces_base 'default' do
  replace_orig true
end

network_interfaces 'br-test' do
  target '172.16.88.2'
  mask '255.255.255.0'
  bridge ['none']
end
```

All interface settings should now be passed as resource properties instead of cookbook node attributes.
