#
# Cookbook Name:: network
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


insert_line_if_no_match("/etc/network/interfaces","^source interfaces.d/*", "source interfaces.d/*")


directory "/etc/network/interfaces.d" do
  owner "root"
  group "root"
  mode "0644"
  action :create
end

private

require 'fileutils'

def insert_line_if_no_match(filepath, regex, newline)
  @original_pathname = filepath
  @file_edited = false
  raise ArgumentError, "File doesn't exist" unless File.exist? @original_pathname
  raise ArgumentError, "File is blank" unless (@contents = File.new(@original_pathname).readlines).length > 0

  exp = Regexp.new(regex)
  new_contents = []
  contents.each do |line|
    if line.match(exp)
      self.file_edited = true
    end
  end
  if ! file_edited
    new_contents << newline
    self.file_edited = true
  end
  if file_edited
    backup_pathname = original_pathname + ".old"
    FileUtils.cp(original_pathname, backup_pathname, :preserve => true)
    File.open(original_pathname, "w") do |newfile|
      contents.each do |line|
        newfile.puts(line)
      end
      newfile.flush
    end
  end
end
