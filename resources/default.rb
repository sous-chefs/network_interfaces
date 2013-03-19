def initialize(*args)
  super
  @action = :save
end

actions :save, :remove

attribute :device, :kind_of => String, :name_attribute => true
attribute :bridge, :kind_of => [ TrueClass, FalseClass, Array ]
attribute :bridge_stp, :kind_of => [ TrueClass, FalseClass ]
attribute :bond, :kind_of => [ TrueClass, FalseClass, Array ]
attribute :bond_mode, :kind_of => String
attribute :vlan_dev, :kind_of => String
attribute :onboot, :kind_of => [ TrueClass, FalseClass ], :default => true
attribute :bootproto, :kind_of => String
attribute :target, :kind_of => String
attribute :gateway, :kind_of => String
attribute :metric, :kind_of => Integer
attribute :mtu, :kind_of => Integer
attribute :mask, :kind_of => String
attribute :network, :kind_of => String
attribute :broadcast, :kind_of => String
attribute :pre_up, :kind_of => String
attribute :up, :kind_of => String
attribute :post_up, :kind_of => String
attribute :pre_down, :kind_of => String
attribute :down, :kind_of => String
attribute :post_down, :kind_of => String
attribute :custom, :kind_of => Hash
