require 'socket'
require 'timeout'

class Chef
  module Zabbix
    class << self
      # Creates a Zabbix connection and passes it to the block provided
      #
      # @param [Hash] connection_spec The specification for your Zabbix connection
      # @option connection_spec [String] :url The Url to your Zabbix server's api_jsonrpc.php endpoint
      # @option connection_spec [String] :user The username to log in as
      # @option connection_spec [String] :password The password for your user
      #
      # @yieldparam [ZabbixApi] connection The connection to the Zabbix server
      def with_connection(connection_spec, &block)
        validate_connection(connection_spec)
        connection = ZabbixApi.connect(connection_spec)
        block.call(connection)
      end

      def validate_connection(connection_spec)
        return if [:url, :user, :password].all? { |key| !connection_spec[key].to_s.empty? }
        Chef::Log.error('invalid connection')
      end
    end
  end
end
