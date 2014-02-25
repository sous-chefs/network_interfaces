require 'spec_helper'

describe 'network_interfaces::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  # TODO: Add some actual tests
  # it 'adds network interfaces' do
  #   # Nothing yet
  # end
end
