class Chef::Recipe::Network_interfaces
  def self.conf(interface,workingnode=@node)
    if workingnode.has_key?("network_interfaces") and workingnode["network_interfaces"].has_key?("interface")
      return workingnode[:network_interfaces][interface]
    else
      return {}
    end
  end

  def self.value(key,interfaces, resource=@new_resource, workingnode=@node)
    !resource.send(key).nil? ? resource.send(key) : self.conf(interfaces,workingnode).has_key?(key) ? self.conf(interfaces,workingnode)[key] : nil
  end
end


module Mod_Network_interfaces
  def debian_before_or_squeeze?
    platform?("debian") && (node['platform_version'].to_f < 6.0 || (node['platform_version'].to_f == 6.0 && node['platform_version'] !~ /.*sid/ ))
  end

  def ubuntu_before_or_natty?
    platform?("ubuntu") && node['platform_version'].to_f <= 11.04 
  end

  def insert_line_if_no_match(filepath, regex, newline)
    @original_pathname = filepath
    @file_edited = false
    raise ArgumentError, "File doesn't exist" unless File.exist? @original_pathname
    raise ArgumentError, "File is blank" unless (@contents = File.new(@original_pathname).readlines).length > 0

    exp = Regexp.new(regex)
    new_contents = []
    @contents.each do |line|
      if line.match(exp)
        @file_edited = true
      end
    end
    if ! @file_edited
      @contents << newline
      backup_pathname = @original_pathname + ".old"
      FileUtils.cp(@original_pathname, backup_pathname, :preserve => true)
      File.open(@original_pathname, "w") do |newfile|
        @contents.each do |line|
          newfile.puts(line)
        end
        newfile.flush
      end
    end
  end
end
