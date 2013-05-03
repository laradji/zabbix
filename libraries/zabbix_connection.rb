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
        if [:url, :user, :password].any? { |key| connection_spec[key].to_s.empty? }
          raise InvalidZabbixServerSpecificationError.new(connection_spec)
        end
      end
    end

    class HostInterface
      TYPES = {
        :agent => 1, 
        :snmp  => 2,
        :ipmi  => 3,
        :jmx   => 4
      }.freeze

      attr_reader :dns, :hostid, :ip, :main, :port, :type, :useip

      class << self
        def dns(dns, port=10050)
          HostInterface.new(false, '', dns, port)
        end

        def ip(ip, port=10050)
          HostInterface.new(true, ip, '', port)
        end
      end

      # Creates a HostInterface object
      #
      # @param [Boolean] useip Whether or not to use the IP address for this interface
      # @param [#to_s] ip The IP address of the host
      # @param [#to_s] dns The DNS name of the host
      # @param [#to_s] port The port to connect to
      # @param [Boolean] main Is this the main interface for this host and type
      # @param [Symbol] type The type of connection. Must be one of [:agent, :snmp, :ipmi, :jmx]
      # @param [#to_s] hostid The id of the host this interface belongs to, this can be blank
      def initialize(useip, ip, dns, port=10050, main=true, type=:agent, hostid='')
        @useip = useip ? 1 : 0
        @ip = ip
        @dns = dns
        @port = port
        @main = main ? 1 : 0
        @type = TYPES[type]
        @hostid = hostid
        raise UnknownHostInterfaceTypeError(type) unless @type
      end

      def to_argument
        { 
          :useip => @useip,
          :ip => @ip,
          :dns => @dns,
          :port => @port,
          :main => @main,
          :type => @type,
          :hostid => @hostid
        }
      end
    end
  end
end
