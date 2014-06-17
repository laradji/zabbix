actions :create # , :delete
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :server_connection, :kind_of => Hash, :required => true
attribute :group, :kind_of => String, :default => 'Templates'
