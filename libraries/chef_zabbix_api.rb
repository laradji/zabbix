class Chef
  module Zabbix
    module API
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

        def find_item_ids(connection, template_id, name, key)
          request = {
            :method => "item.get",
            :params => {
              :hostids => template_id,
              :filter => {
                :name => name
              },
              :search => {
                :key_ => key
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

          attr_reader :value
          def initialize(value)
            @value = value
          end 

          def enum(name, val)
            klass = class << self; self; end 
            klass.send(:define_method, name) do
              @values ||= {}
              @values[name] ||= new(val)
            end 
          end 
        end 
      end

      class ItemType
        include Enumeration
        enum :agent,            0
        enum :snmp_v1,          1
        enum :trapper,          2
        enum :simple_check,     3
        enum :snmp_v2,          4
        enum :internal,         5
        enum :snmp_v3,          6
        enum :active_check,     7
        enum :aggregate,        8
        enum :http_test,        9
        enum :external,         10
        enum :database_monitor, 11
        enum :ipmi,             12
        enum :ssh,              13
        enum :telnet,           14
        enum :calculated,       15
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


    end
  end
end
