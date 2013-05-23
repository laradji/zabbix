class Chef
  module Zabbix
    module API
      class << self
        def find_hostgroup_ids(connection, hostgroup)
          group_id_request = {
            :method => "hostgroup.get",
            :params => { 
              :filter => {
                :name => new_resource.group
              }
            }
          }
          connection.query(group_id_request)
        end

        def find_template_ids(connection, template)
          get_template_request = {
            :method => "template.get",
            :params => {
              :filter => {
                :host => template,
              }
            }
          }
          connection.query(get_template_request) 
        end

        def find_applicaiton_ids(connection, application, host_id)
          request = {
            :method => "application.get",
            :params => {
              :hostids => host_id,
              :filter => { 
                :name => application
              }
            }
          }
          connection.query(request)
        end
      end
    end
  end
end
