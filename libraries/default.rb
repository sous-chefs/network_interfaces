# A set of methods for interacting with this cookbooks attributes
# and any attributes being set on a new resource
class Chef::Recipe::NetworkInterfaces
  def self.conf(interface, workingnode = @node)
    if workingnode.key?('network_interfaces') && workingnode['network_interfaces'].key?('interface')
      return workingnode[:network_interfaces][interface]
    else
      return {}
    end
  end

  def self.value(key, interfaces, resource = @new_resource, workingnode = @node)
    if !resource.send(key).nil?
      resource.send(key)
    else
      if conf(interfaces, workingnode).key?(key)
        conf(interfaces, workingnode)[key]
      else
        nil
      end
    end
  end
end
