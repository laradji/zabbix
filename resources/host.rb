actions :create_or_update
default_action :create_or_update

attribute :hostname, :kind_of => String, :name_attribute => true
attribute :server_connection, :kind_of => Hash, :default => Hash.new
attribute :interfaces, :kind_of => Array, :default => Array.new
attribute :groups, :kind_of => Array, :default => Array.new
attribute :create_missing_groups, :kind_of => [TrueClass, FalseClass], :default => false
