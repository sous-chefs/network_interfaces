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

# Reset ifaces order on each run
node.set['network_interfaces']['order'] = []

legacy_debian = ((platform?('debian') &&
    node['platform_version'].to_f <= 6.0) ||
  (platform?('ubuntu') &&
    node['platform_version'].to_f <= 11.04))

ruby_block 'Merge interfaces' do
  block do
    File.open('/etc/network/interfaces', 'w') do |ifaces|
      (['/etc/network/interfaces.tpl'] + node['network_interfaces']['order'].map { |ifile| "/etc/network/interfaces.d/#{ifile}" }).uniq.compact.each do |ifile|
        File.open(ifile) do |f|
          f.each_line { |line| ifaces.write(line) }
        end
      end
    end
  end
  only_if { legacy_debian }
  action :nothing
end

cookbook_file 'interfaces' do
  if legacy_debian
    path '/etc/network/interfaces.tpl'
  elsif node['network_interfaces']['replace_orig']
    path '/etc/network/interfaces'
  end
  mode '0644'
  owner 'root'
  group 'root'
  only_if { node['network_interfaces']['replace_orig'] }
end

file '/etc/network/interfaces' do
  if File.exist?('/etc/network/interfaces')
    new_content = File.read('/etc/network/interfaces')
  else
    new_content = "auto lo\n" \
      "iface lo inet loopback\n" \
      "\n"
  end
  content "#{new_content}\n" \
    "# The following was added by the Chef network_interfaces cookbook:\n" \
    "source /etc/network/interfaces.d/*\n"
  not_if do
    node['network_interfaces']['replace_orig'] ||
    legacy_debian ||
    File.read('/etc/network/interfaces') =~ %r(^source /etc/network/interfaces.d/\*$)
  end
  action :create
end

directory '/etc/network/interfaces.d' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end
