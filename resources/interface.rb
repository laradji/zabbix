actions :create
default_action :create

attribute :server_connection, :kind_of => Hash, :required => true
attribute :parameters, :kind_of => Hash, :required => true
