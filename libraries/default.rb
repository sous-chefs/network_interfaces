# A set of methods for interacting with this cookbooks attributes
# and any attributes being set on a new resource
#
# What this set of methods actually does:
#
# If a value is not provided with the resource, check the node attributes for
# it.  If the value is present, use that value, otherwise, leave it nil.

class Chef
  class Recipe
    class NetworkInterfaces
      def self.conf(interface, node)
        if node.key?('network_interfaces') &&
          node['network_interfaces'].key?('interface')
          node['network_interfaces'][interface]
        else
          {}
        end
      end

      def self.value(key, interface, resource = @new_resource, node)
        if resource.send(key).nil?
          if conf(interface, node).key?(key)
            conf(interface, node)[key]
          else
            nil
          end
        else
          resource.send(key)
        end
      end
    end
  end
end
