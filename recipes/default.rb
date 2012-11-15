#
# Cookbook Name:: network_interfaces
# Recipe:: default
#
# Author:: Stanislav Bogatyrev <realloc@realloc.spb.ru>
# Author:: Guilhem Lettron <guilhem.lettron@youscribe.com>
#
# Copyright 2012, Clodo.ru
# Copyright 2012, Societe Publica.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef::Recipe
  include Mod_Network_interfaces
end

# Reset ifaces order on each run
node.default["network_interfaces"]["order"]=[]

ruby_block "Merge interfaces" do
  block do
    class  Chef::Resource::RubyBlock
      include Mod_Network_interfaces
    end
    if debian_before_or_squeeze? || ubuntu_before_or_natty?
      File.open("/etc/network/interfaces", "w") do |ifaces|
        ( ["/etc/network/interfaces.tpl"] + node["network_interfaces"]["order"].map{|ifile| "/etc/network/interfaces.d/#{ifile}"} ).uniq.compact.each do |ifile|
          File.open(ifile) do |f|
            f.each_line { |line| ifaces.write(line) }
          end
        end
      end
    end
  end
  action :nothing
end

if (debian_before_or_squeeze? || ubuntu_before_or_natty?)
  cookbook_file "/etc/network/interfaces.tpl" do
    source "interfaces"
    mode 0644
    owner "root"
    group "root"
  end
elsif node["network_interfaces"]["replace_orig"]
  cookbook_file "/etc/network/interfaces" do
    source "interfaces"
    mode 0644
    owner "root"
    group "root"
  end
end

ruby_block "Fix interfaces include" do
  block do
    class  Chef::Resource::RubyBlock
      include Mod_Network_interfaces
    end
    unless debian_before_or_squeeze? || ubuntu_before_or_natty?
      insert_line_if_no_match("/etc/network/interfaces", "^source /etc/network/interfaces.d/*", 'source /etc/network/interfaces.d/*')
    end
  end
end

directory "/etc/network/interfaces.d" do
	owner "root"
	group "root"
	mode "0644"
	action :create
end
