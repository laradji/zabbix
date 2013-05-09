def load_current_resource
  @new_resource
end

action :include do
 chef_gem "zabbixapi" do
    action :install
    version "~> 0.5.9"
  end

  require 'zabbixapi'

  new_resource.updated_by_last_action(true)
end


