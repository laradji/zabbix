actions :create
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :template, :kind_of => String, :required => true
attribute :applications, :kind_of => Array, :required => true
attribute :key, :kind_of => String, :required => true
attribute :type, :kind_of => Chef::Zabbix::API::ItemType, :required => true
attribute :value_type, :kind_of => Chef::Zabbix::API::ItemValueType, :required => true
attribute :server_connection, :kind_of => Hash, :required => true

attribute :delay, :kind_of => Fixnum, :default => 60
attribute :description, :kind_of => String
attribute :snmp_community, :kind_of => String, :default => '{}'
attribute :snmp_oid, :kind_of => String, :default => '{}'
attribute :port, :kind_of => String
attribute :item_params, :kind_of => String
attribute :status, :kind_of => Chef::Zabbix::API::ItemStatus, :default => Chef::Zabbix::API::ItemStatus.enabled
attribute :multiplier, :kind_of => Fixnum
attribute :history, :kind_of => Fixnum, :default => 90
attribute :trends, :kind_of => Fixnum, :default => 365
attribute :allowed_hosts, :kind_of => String
attribute :units, :kind_of => String
attribute :delta, :kind_of => Chef::Zabbix::API::Delta, :default => Chef::Zabbix::API::Delta.as_is
attribute :snmpv3_securityname, :kind_of => String
attribute :snmpv3_securitylevel, :kind_of => Chef::Zabbix::API::SNMPV3SecurityLevel, :default => Chef::Zabbix::API::SNMPV3SecurityLevel.no_auth_no_priv
attribute :snmpv3_authpassphrase, :kind_of => String
attribute :snmpv3_privpassphrase, :kind_of => String
attribute :formula, :kind_of => Fixnum, :default => 1
attribute :delay_flex, :kind_of => String
attribute :ipmi_sensor, :kind_of => String
attribute :data_type, :kind_of => Chef::Zabbix::API::DataType, :default => Chef::Zabbix::API::DataType.decimal
attribute :authtype, :kind_of => Chef::Zabbix::API::AuthType, :default => Chef::Zabbix::API::AuthType.password
attribute :username, :kind_of => String
attribute :password, :kind_of => String
attribute :publickey, :kind_of => String
attribute :privatekey, :kind_of => String
attribute :inventory_link, :kind_of => Fixnum, :default => 0 # TODO: Make an enumeration for this
attribute :valuemap, :kind_of => String

# Setting discovery_rule will cause the item to be created as a prototype
attribute :discovery_rule_key, :kind_of => String, :default => nil
