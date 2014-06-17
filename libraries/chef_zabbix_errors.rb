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
      def initialize(bad_connection_info)
        @bad_connection_info = bad_connection_info
      end

      def to_s
        "MySql connection info must be a Hash containing :host, :dbname, :username and :root keys. Received: #{@bad_connection_info}"
      end
    end

    class InvalidZabbixServerSpecificationError < ZabbixError
      def initialize(bad_connection_spec)
        @bad_connection_spec = bad_connection_spec
      end

      def to_s
        "ZabbixApi connection info must be a Hash containing :url, :user and :password keys. Received: #{@bad_connection_spec}"
      end
    end

    class ServerNotReachableError < ZabbixError
      def initialize(ip, port)
        @ip = ip
        @port = port
      end

      def to_s
        "Zabbix Server not reachable on '#{@ip}:#{@port}'"
      end
    end

    class UnknownHostInterfaceTypeError < ZabbixError
      def initialize(type)
        @type = type
      end

      def to_s
        "Interface type must be one of [:agent, :snmp, :ipmi, :jmx] but received '#{@type}'"
      end
    end

    class HostGroupNotFoundError < ZabbixError
      def initialize(group)
        @group = group
      end

      def to_s
        "Could not find a HostGroup named '#{@group}'"
      end
    end

    class InvalidDataTypeError < ZabbixError
      def initialize(data_type)
        @data_type = data_type
      end

      def message
        "Data Type '#{data_type}' is not known.\n
        Known Data Types: \n
         -- hostgroups\n
         -- templates\n
         -- applications\n
        "
      end
    end

    class InvalidApiMethodError < ZabbixError
      def initialize(data_type, method)
        @data_type = data_type
        @method = method
      end

      def message
        "Method '#{@method}' is unknown for Data Type '#{@data_type}'"
      end
    end

    class InvalidParametersHashError < ZabbixError
      def initialize(bad_params)
        @bad_params = bad_params
      end

      def message
        "Expected parameters to be a Hash but got '#{@bad_params.class}': #{@bad_params}"
      end
    end
  end
end
