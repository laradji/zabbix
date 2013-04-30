#
# Cookbook Name:: zabbix
# Library:: chef_zabbix_errors
#
# Author:: Andrew Garson(<agarson@riotgames.com, andrew.garson@gmail.com>)
#

class Chef
  module Zabbix
    class ZabbixError < StandardError; end

    class InvalidMySqlConnectionInfoError < ZabbixError
      def message(bad_connection_info)
        "MySql connection info must be a Hash containing :host, :dbname, :username and :root keys. Received: #{bad_connection_info}"
      end
    end

    class InvalidZabbixServerSpecificationError < StandardError
      def message(bad_connection_spec)
        "ZabbixApi connection info must be a Hash containing :url, :user and :password keys. Received: #{bad_connection_spec}"
      end
    end

    class ServerNotReachableError
      def message(ip, port)
        "Zabbix Server not reachable on '#{ip}:#{port}'"
      end
    end
  end
end
