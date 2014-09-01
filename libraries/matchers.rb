if defined?(ChefSpec)
  def save_network_interfaces(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:network_interfaces, :save, resource_name)
  end

  def remove_network_interfaces(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:network_interfaces, :remove, resource_name)
  end
end
