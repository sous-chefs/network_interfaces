class Chef::Recipe::Network_interfaces
	def self.conf(interface,workingnode=@node)
		if workingnode.has_key?("network_interfaces") and workingnode["network_interfaces"].has_key?("interface")
			return workingnode[:network_interfaces][interface]
		else
			return {}
		end
	end

	def self.value(key,interfaces, resource=@new_resource, workingnode=@node)
		resource.send(key) ? resource.send(key) : self.conf(interfaces,workingnode).has_key?(key) ? self.conf(interfaces,workingnode)[key] : false
	end
end
