actions :create
default_action :create

attr_accessor :exists

def initialize(name, run_context = nil)
  super
  @provider ||= Chef::Provider::ZabbixDatabaseMySql
end

attribute :dbname, :kind_of => String, :name_attribute => true
attribute :host, :kind_of => String, :required => true
attribute :port, :kind_of => Integer, :required => true
attribute :username, :kind_of => String, :required => true
attribute :password, :kind_of => String, :required => true
attribute :root_username, :kind_of => String, :required => true
attribute :root_password, :kind_of => String, :required => true
attribute :allowed_user_hosts, :kind_of => String, :default => ''

attribute :server_version, :kind_of => String, :required => true
attribute :source_url, :kind_of => String, :required => true
attribute :source_dir, :kind_of => String, :required => true
attribute :install_dir, :kind_of => String, :required => true
attribute :branch, :kind_of => String, :required => false
attribute :version, :kind_of => String, :required => false
