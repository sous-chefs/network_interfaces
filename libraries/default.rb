# frozen_string_literal: true

module NetworkInterfacesCookbook
  module Helpers
    DEFAULT_INTERFACES_CONTENT = <<~INTERFACES
      auto lo
      iface lo inet loopback
    INTERFACES

    def interfaces_content(path, source_glob)
      content = if ::File.exist?(path)
                  ::File.read(path).rstrip
                else
                  DEFAULT_INTERFACES_CONTENT.rstrip
                end

      "#{content}\n\n# The following was added by the Chef network_interfaces cookbook:\nsource #{source_glob}\n"
    end

    def source_line_present?(path, source_glob)
      ::File.exist?(path) && ::File.read(path).match?(/^source #{Regexp.escape(source_glob)}$/)
    end

    def interface_type
      if new_resource.bootproto == 'dhcp'
        'dhcp'
      elsif new_resource.type
        new_resource.type
      elsif new_resource.target
        'static'
      else
        'manual'
      end
    end

    def normalized_option(value)
      return ['none'] if value == true
      return if value == false

      value
    end

    def up_down_commands
      {
        pre_up: Array(new_resource.pre_up),
        up: Array(new_resource.up),
        post_up: Array(new_resource.post_up),
        pre_down: Array(new_resource.pre_down),
        down: Array(new_resource.down),
        post_down: Array(new_resource.post_down),
      }
    end
  end
end
