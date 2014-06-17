actions :create_or_update, :create, :update, :link
default_action :create_or_update

attribute :hostname, :kind_of => String, :name_attribute => true

attribute :ipmi_auth_type, :kind_of => Chef::Zabbix::API::IPMIAuthType, :default => Chef::Zabbix::API::IPMIAuthType.default
attribute :ipmi_privilege, :kind_of => Chef::Zabbix::API::IPMIPrivilege, :default => Chef::Zabbix::API::IPMIPrivilege.user
attribute :ipmi_username, :kind_of => String
attribute :ipmi_password, :kind_of => String

attribute :monitored, :kind_of => [TrueClass, FalseClass], :default => true

attribute :interfaces, :kind_of => Array, :default => []
attribute :templates, :kind_of => Array, :default => []
attribute :groups, :kind_of => Array, :default => []
attribute :macros, :kind_of => Hash, :default => {}

# See https://www.zabbix.com/documentation/2.0/manual/appendix/api/host/definitions#host
# for appropriate inventory hash keys (Property name from the table)
attribute :inventory, :kind_of => Hash, :default => {}

attribute :interfaces, :kind_of => Array, :default => []

attribute :server_connection, :kind_of => Hash, :default => {}
attribute :create_missing_groups, :kind_of => [TrueClass, FalseClass], :default => false
attribute :parameters, :kind_of => Hash, :default => {}
