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
  end
end
