class Chef::Recipe::Network_interfaces
  def self.conf(interface, workingnode = @node)
    if workingnode.key?('network_interfaces') && workingnode['network_interfaces'].key?('interface')
      return workingnode[:network_interfaces][interface]
    else
      return {}
    end
  end

  def self.value(key, interfaces, resource = @new_resource, workingnode = @node)
    !resource.send(key).nil? ? resource.send(key) : conf(interfaces, workingnode).key?(key) ? conf(interfaces, workingnode)[key] : nil
  end
end
