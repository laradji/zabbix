actions :create, :delete
default_action :create

attribute :name, :kind_of => String, :required => true
attribute :server_connection, :kind_of => Hash, :required => true
attribute :group, :kind_of => String, :default => "Templates"
