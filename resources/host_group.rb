actions :create
default_action :create

attr_accessor :exists

attribute :group, :kind_of => String, :name_attribute => true
attribute :server_connection, :kind_of => Hash, :default => {}
