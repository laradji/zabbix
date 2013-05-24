actions :create
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :description, :kind_of => String
attribute :key, :kind_of => String, :required => true
attribute :template, :kind_of => String, :required => true
attribute :applications, :kind_of => Array, :required => true
attribute :type, :kind_of => Zabbix::API::ItemType, :required => true
attribute :value_type, :kind_of => Zabbix::API::ItemValueType, :required => true
attribute :server_connection, :kind_of => Hash, :required => true
attribute :delay, :kind_of => Fixnum, :required => true
attribute :snmp_community, :kind_of => String, :default => '{}' #investigate if there is a better way to do these two
attribute :snmp_oid, :kind_of => String, :default => '{}'
attribute :port, :kind_of => String

