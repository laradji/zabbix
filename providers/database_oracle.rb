# Stub Oracle provider

use_inline_resources

def whyrun_supported?
  true
end

def load_current_resource
  true
end

def database_exists?(_dbname, _host, _port, _root_username, _root_password)
  true
end

action :create do
  Chef::Log.info 'Oracle provider is a stub - does not do anything yet!'
end

def create_new_database
  true
end
