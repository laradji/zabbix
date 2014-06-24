actions :register
default_action :register

attribute :name, :kind_of => String, :name_attribute => true
attribute :master, :kind_of => String
attribute :server_connection, :kind_of => Hash, :default => {}
