actions :create
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :key, :kind_of => String, :required => true
attribute :type, :kind_of => Chef::Zabbix::API::ItemType, :required => true
attribute :template, :kind_of => String, :required => true
attribute :server_connection, :kind_of => Hash, :required => true

attribute :delay, :kind_of => Fixnum, :default => 30
attribute :authtype, :kind_of => Chef::Zabbix::API::AuthType, :default => Chef::Zabbix::API::AuthType.password
attribute :lifetime, :kind_of => Fixnum, :default => 30

attribute :delay_flex, :kind_of => String
attribute :description, :kind_of => String
attribute :filter, :kind_of => String
attribute :ipmi_sensor, :kind_of => String
attribute :discovery_rule_params, :kind_of => String
attribute :password, :kind_of => String
attribute :port, :kind_of => String
attribute :privatekey, :kind_of => String
attribute :publickey, :kind_of => String
attribute :snmp_community, :kind_of => String, :default => '{}'
attribute :snmp_oid, :kind_of => String, :default => '{}'
attribute :snmpv3_securityname, :kind_of => String
attribute :snmpv3_authpassphrase, :kind_of => String
attribute :snmpv3_privpassphrase, :kind_of => String
attribute :snmpv3_securitylevel, :kind_of => Chef::Zabbix::API::SNMPV3SecurityLevel, :default => Chef::Zabbix::API::SNMPV3SecurityLevel.no_auth_no_priv
attribute :status, :kind_of => Chef::Zabbix::API::ItemStatus, :default => Chef::Zabbix::API::ItemStatus.enabled
attribute :allowed_hosts, :kind_of => String
attribute :username, :kind_of => String
