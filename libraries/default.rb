# A set of methods for interacting with this cookbooks attributes
# and any attributes being set on a new resource
class Chef
  class Recipe
    class NetworkInterfaces
      def self.conf(interface, workingnode = @node)
        if workingnode.key?('network_interfaces') && workingnode['network_interfaces'].key?('interface')
          workingnode[:network_interfaces][interface]
        else
          {}
        end
      end

      def self.value(key, interfaces, resource = @new_resource, workingnode = @node)
        if !resource.send(key).nil?
          resource.send(key)
        elsif conf(interfaces, workingnode).key?(key)
          conf(interfaces, workingnode)[key]
        end
      end
    end
  end
end
