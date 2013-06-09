require 'forwardable'

class Chef
  module Zabbix
    module API

      class GraphItem
        extend Forwardable
        def_delegators :@options, :[], :[]=, :delete
        def initialize(options)
          if options[:item_template].to_s.empty? && options[:host].to_s.empty?
            Chef::Application.fatal! ":item_template or :host is required"
          end
          Chef::Application.fatal! ":item_key is required" if options[:item_key].to_s.empty?
          Chef::Application.fatal! ":calc_function must be a Zabbix::API::GraphItemCalcFunction" unless options[:calc_function].kind_of?(GraphItemCalcFunction)
          Chef::Application.fatal! ":type must be a Zabbix::API::GraphItemType" unless options[:type].kind_of?(GraphItemType)
          @options = options
        end

        def to_hash
          unless @options[:itemid]
            Chef::Application.fatal! ":itemid was never set. This probably means that an item with key '#{@options[:item_key]}' couldn't be found on template '#{@options[:item_template]}'"
          end
          {
            :itemid => @options[:itemid],
            :color => @options[:color],
            :calc_fnc => @options[:calc_function].value,
            :type => @options[:type].value,
            :periods_cnt => @options[:period_count]
          }
        end
      end

      class HostInterface

        class << self
          def from_api_response(options)
            options["type"] = Zabbix::API::HostInterfaceType.enumeration_values.detect { |value| value[1].value == options["type"].to_i }[1]
            options["main"] = (options["main"].to_i == 1)
            options["useip"] = (options["useip"].to_i == 1)
            new(options)
          end
        end

        attr_reader :options

        extend Forwardable
        def_delegators :@options, :[], :[]=, :delete
        def initialize(options)
          options = symbolize(options)
          if options[:type].is_a?(Fixnum)
          end
          validate!(options)
          @options = options
        end

        def to_hash
          {
            :dns => @options[:dns].to_s,
            :ip => @options[:ip].to_s,
            :useip => (@options[:useip]) ? 1 : 0,
            :main => (@options[:main]) ? 1 : 0,
            :port => @options[:port].to_s,
            :type => @options[:type].value
          }
        end

        def ==(other)
          this = self.to_hash
          this[:main]    == other[:main].to_i &&
            this[:useip] == other[:useip].to_i &&
            this[:ip]    == other[:ip].to_s &&
            this[:dns]   == other[:dns].to_s &&
            this[:port]  == other[:port].to_s &&
            this[:type]  == other[:type].to_i
        end

        private 
          def validate!(options)
            options = symbolize(options)
            Chef::Application.fatal!(":main must be one of [true, false]") unless [true, false].include?(options[:main])
            Chef::Application.fatal!(":useip must be one of [true, false]") unless [true, false].include?(options[:useip])
            if options[:useip]
              search = :ip
            else
              search = :dns
            end
            Chef::Application.fatal!("#{search} must be set when :useip is #{options[:useip]}") if options[search].to_s.empty?
            Chef::Application.fatal!(":port is required") if options[:port].to_s.empty?
            Chef::Application.fatal!(":type must be a Chef::Zabbix::API:HostInterfaceType") unless options[:type].kind_of?(Chef::Zabbix::API::HostInterfaceType)
          end

          def symbolize(options)
            symbolized = {}
            options.each_key do |key|
              symbolized[key.to_sym] = options[key]
            end
            symbolized
          end
      end

      class << self


        def find_hostgroup_ids(connection, hostgroup)
          group_id_request = {
            :method => "hostgroup.get",
            :params => { 
              :filter => {
                :name => hostgroup
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

        def find_application_ids(connection, application, template_id)
          request = {
            :method => "application.get",
            :params => {
              :hostids => template_id,
              :filter => { 
                :name => application
              }
            }
          }
          connection.query(request)
        end

        def find_item_ids(connection, template_id, key, name=nil)
          request = {
            :method => "item.get",
            :params => {
              :hostids => template_id,
              :search => {
                :key_ => key
              }
            }
          }
          unless name.to_s.empty?
            request[:filter] = {
              :name => name
            }
          end

          connection.query(request)
        end

        def find_item_ids_on_host(connection, host, key) 
          request = {
            :method => "item.get",
            :params => {
              :host => host,
              :search => {
                :key_ => key
              }
            }
          }
          connection.query(request)
        end

        def find_graph_ids(connection, name)
          request = {
            :method => "graph.get",
            :params => {
              :filter => {
                :name => name
              }
            }
          }
          connection.query(request)
        end
      end

      module  Enumeration
        class << self
          def included(base)
            base.extend(ClassMethods)
            base.send(:include, ClassMethods)
          end 

          def extended(base)
            base.send(:include, ClassMethods)
          end 
        end 

        module ClassMethods
          attr_reader :enumeration_values
          def enum(name, val)
            @enumeration_values ||= {}
            @enumeration_values[name] ||= new(val)
            # The better solution would be to just call define_singleton_method
            # but that doesn't work in 1.8.x and we want 1.8.x compatibility
            eigen_class = class << self; self; end
            eigen_class.send(:define_method, name) do
              @enumeration_values[name]
            end
          end
        end

        attr_reader :value
        def initialize(value)
          @value = value
        end 
      end 

      class ItemType
        include Enumeration
        enum :zabbix_agent,               0
        enum :snmp_v1_agent,              1
        enum :zabbix_trapper,             2
        enum :simple_check,               3
        enum :snmp_v2_agent,              4
        enum :zabbix_internal,            5
        enum :snmp_v3_agent,              6
        enum :zabbix_agent_active_check,  7
        enum :zabbix_aggregate,           8
        enum :web_item,                   9
        enum :externali_check ,           10
        enum :database_monitor,           11
        enum :ipmi_agent,                 12
        enum :ssh_agent,                  13
        enum :telnet_agent,               14
        enum :calculated,                 15
        enum :jmx_agent,                  16
        enum :snmp_trap,                  17
      end

      class ItemValueType
        include Enumeration
        enum :float, 0
        enum :character, 1
        enum :log, 2
        enum :unsigned, 3
        enum :text, 4
      end

      class TriggerPriority
        include Enumeration

        enum :not_classified, 0 
        enum :information, 1
        enum :warning, 2
        enum :average, 3
        enum :high, 4
        enum :disaster, 5
      end

      class TriggerStatus
        include Enumeration
        enum :active, 0
        enum :disabled, 1
      end

      class TriggerType
        include Enumeration
        enum :normal, 0
        enum :multiple, 1
      end

      class GraphItemCalcFunction
        include Enumeration
        enum :min,      1
        enum :max,      2
        enum :average,  4
        enum :all,      7
      end

      class GraphItemType
        include Enumeration
        enum :simple,     0
        enum :aggregated, 1
        enum :graph,      2
      end

      class GraphType
        include Enumeration
        enum :normal, 0
        enum :stacked, 1
        enum :pie, 2
        enum :exploded, 3
      end

      class GraphAxisType
        include Enumeration
        enum :calculated, 0
        enum :fixed, 1
        # TODO: Update the graph provider to do an update after it has created
        # all of its item so that you can map an item id and support this value
        #enum :item, 2
      end

      class IPMIAuthType
        include Enumeration
        enum :default,   -1
        enum :none,       0
        enum :md2,        1
        enum :md5,        2
        enum :straight,   3
        enum :oem,        4
        enum :rmcp_plus,  5
      end

      class IPMIPrivilege
        include Enumeration
        enum :callback,   1
        enum :user,       2
        enum :operator,   3
        enum :admin,      4
        enum :oem,        5
      end

      class HostInterfaceType
        include Enumeration
        enum :agent,  1
        enum :snmp,   2
        enum :ipmi,   3
        enum :jmx,    4
      end
    end
  end
end
