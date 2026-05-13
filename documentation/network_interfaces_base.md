# network_interfaces_base

Manages the base `/etc/network/interfaces` file and the `/etc/network/interfaces.d` directory.

## Actions

* `:create` - Creates the base interfaces file and include directory. Default.
* `:delete` - Removes the managed source line and interfaces include directory.

## Properties

* `interfaces_path` - String, default `'/etc/network/interfaces'`. Path to the base interfaces file.
* `interfaces_dir` - String, default `'/etc/network/interfaces.d'`. Directory for interface fragments.
* `source_glob` - String, default `'/etc/network/interfaces.d/*'`. Source glob added to the base file.
* `replace_orig` - true or false, default `false`. Replace the base file instead of preserving existing content.

## Examples

### Preserve existing content and add source line

```ruby
network_interfaces_base 'default'
```

### Replace the base file

```ruby
network_interfaces_base 'default' do
  replace_orig true
end
```
