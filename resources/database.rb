actions :create
default_action :create

attribute :dbname, :kind_of => String, :name_attribute => true
attribute :host, :kind_of => String, :required => true
attribute :username, :kind_of => String, :required => true
attribute :password, :kind_of => String, :required => true
attribute :root_username, :kind_of => String, :required => true
attribute :root_password, :kind_of => String, :required => true
attribute :allowed_user_hosts, :kind_of => String, :required => true
attribute :zabbix_source_dir, :kind_of => String, :required => true
attribute :zabbix_server_version, :kind_of => String, :required => true
