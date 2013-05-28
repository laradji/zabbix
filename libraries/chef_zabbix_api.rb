require 'forwardable'

class Chef
  module Zabbix
    module API

      class GraphItem
        extend Forwardable
        def_delegators :@options, :[], :[]=, :delete
        def initialize(options)
          Chef::Application.fatal! ":item_template is required" if options[:item_template].to_s.empty?
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

        def find_graph_ids(connection, template_id, name)
          request = {
            :method => "graph.get",
            :params => {
              :filter => {
                :name => name
              },
              :search => {
                :hostid => template_id
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
            define_singleton_method(name) do
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
    end

  end
end
