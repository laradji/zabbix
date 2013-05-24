actions :create
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :server_connection, :kind_of => Hash, :required => true
attribute :template, :kind_of => String, :required => true
