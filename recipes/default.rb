#
# Cookbook Name:: network
# Recipe:: default
#
# Author:: Guilhem Lettron <guilhem.lettron@youscribe.com>
#
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
require 'fileutils'

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

if node["network_interfaces"]["replace_orig"] 
  cookbook_file "/etc/network/interfaces" do
    source "interfaces"
    mode 0644
    owner "root"
    group "root"
  end  
end

insert_line_if_no_match("/etc/network/interfaces", "^source /etc/network/interfaces.d/*", 'source /etc/network/interfaces.d/*')

directory "/etc/network/interfaces.d" do
	owner "root"
	group "root"
	mode "0644"
	action :create
end
