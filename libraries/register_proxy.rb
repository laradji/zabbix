class Chef
  module Zabbix
    module RegisterProxy
      def register_proxy(master, server_connection)
        # The "master" param is actually not required but makes logging easier
        # May be refactored away if need be.
        Chef::Zabbix.with_connection(server_connection) do |connection|
          get_proxies = {
            :method => 'proxy.get',
            :params => {
              :output => 'extend',
              :filter => { :host => node.name }
            }
          }
          proxy = connection.query(get_proxies)

          if proxy.nil? || proxy.empty?
            Chef::Log.info "Creating Zabbix proxy #{node.name} on #{master}"
            # Create proxy - hosts are assigned separately in the agent
            # auto registration phase.
            begin
              result = connection.query(
                :method => 'proxy.create',
                :params => {
                  :host => node.name,
                  :status => '5'
                }
              )
              if result['proxyids']
                Chef::Log.info "Created proxy with name #{master} and ID #{result['proxyids'].first}"
              else
                Chef::Application.fatal! "Zabbix server failed to return proxy; guru meditation :  #{result}"
              end
            rescue RuntimeError => e
              Chef::Application.fatal! "Failed to create proxy. Diagnosis information follows : - #{e.message}"
            end
            # For determining if the resource was updated.
            return true
          else
            Chef::Log.info 'Proxy already exists - doing nothing.'
            # For determining if the resource was updated.
            return false
          end
        end
      end
    end
  end
end
