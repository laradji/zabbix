# Stub Oracle provider
def whyrun_supported?
  true
end

def load_current_resource
  true
end

def database_exists?(dbname, host, port, root_username, root_password)
  true
end

action :create do
  Chef::Log.info 'Oracle provider is a stub - does not do anything yet!'
end

def create_new_database
  true
end
