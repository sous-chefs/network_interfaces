#
# Cookbook:: network_interfaces
# Spec:: default
#
# Copyright:: 2021, Jeff Byrnes.
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

require 'spec_helper'

describe 'network_interfaces::default' do
  platform 'ubuntu'

  context 'with default attributes' do
    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    # TODO: Add actual tests
    it 'adds network interfaces' do
      pending 'Unit tests'
      raise
    end
  end
end
