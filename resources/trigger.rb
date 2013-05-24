actions :create
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :description, :kind_of => String, :required => true
attribute :expression, :kind_of => String, :required => true
attribute :priority, :kind_of => Zabbix::API::TriggerPriority, :required => true
attribute :status, :kind_of => Zabbix::API::TriggerStatus, :default => Zabbix::API::TriggerStatus.active
attribute :template, :kind_of => String, :required => true
attribute :application, :kind_of => String, :required => true
attribute :type, :kind_of => Zabbix::API::TriggerType, :default => Zabbix::API::TriggerType.normal

attribute :server_connection, :kind_of => Hash, :required => true
