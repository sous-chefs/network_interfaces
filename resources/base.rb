# frozen_string_literal: true

provides :network_interfaces_base
unified_mode true

property :interfaces_path, String, default: '/etc/network/interfaces'
property :interfaces_dir, String, default: '/etc/network/interfaces.d'
property :source_glob, String, default: '/etc/network/interfaces.d/*'
property :replace_orig, [true, false], default: false

default_action :create

action :create do
  directory ::File.dirname(new_resource.interfaces_path) do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
  end

  file new_resource.interfaces_path do
    content NetworkInterfacesCookbook::Helpers::DEFAULT_INTERFACES_CONTENT + "\nsource #{new_resource.source_glob}\n"
    owner 'root'
    group 'root'
    mode '0644'
    only_if { new_resource.replace_orig }
  end

  file new_resource.interfaces_path do
    content lazy { interfaces_content(new_resource.interfaces_path, new_resource.source_glob) }
    owner 'root'
    group 'root'
    mode '0644'
    not_if { new_resource.replace_orig || source_line_present?(new_resource.interfaces_path, new_resource.source_glob) }
  end

  directory new_resource.interfaces_dir do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end

action :delete do
  delete_lines "remove source #{new_resource.source_glob}" do
    path new_resource.interfaces_path
    pattern "^source #{Regexp.escape(new_resource.source_glob)}$"
    ignore_missing true
  end

  directory new_resource.interfaces_dir do
    recursive true
    action :delete
  end
end

action_class do
  include NetworkInterfacesCookbook::Helpers
end
