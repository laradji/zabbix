require 'forwardable'

class Chef
  module Zabbix
    module API
      class GraphItem
        extend Forwardable
        def_delegators :@options, :[], :[]=, :delete
        def initialize(options)
          if options[:item_template].to_s.empty? && options[:host].to_s.empty?
            Chef::Application.fatal! ':item_template or :host is required'
          end
          Chef::Application.fatal! ':item_key is required' if options[:item_key].to_s.empty?
          Chef::Application.fatal! ':calc_function must be a Zabbix::API::GraphItemCalcFunction' unless options[:calc_function].is_a?(GraphItemCalcFunction)
          Chef::Application.fatal! ':type must be a Zabbix::API::GraphItemType' unless options[:type].is_a?(GraphItemType)
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
            options['type'] = Zabbix::API::HostInterfaceType.enumeration_values.find { |value| value[1].value == options['type'].to_i }[1]
            options['main'] = (options['main'].to_i == 1)
            options['useip'] = (options['useip'].to_i == 1)
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
          this = to_hash
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
          search = options[:useip] ? :ip : :dns
          Chef::Application.fatal!("#{search} must be set when :useip is #{options[:useip]}") unless options[search]
          Chef::Application.fatal!(':port is required') unless options[:port]
          Chef::Application.fatal!(':type must be a Chef::Zabbix::API:HostInterfaceType') unless options[:type].is_a?(Chef::Zabbix::API::HostInterfaceType)
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
            :method => 'hostgroup.get',
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
            :method => 'template.get',
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
            :method => 'application.get',
            :params => {
              :hostids => template_id,
              :filter => {
                :name => application
              }
            }
          }
          connection.query(request)
        end

        def find_lld_rule_ids(connection, template_id, key)
          request = {
            :method => 'discoveryrule.get',
            :params => {
              :templated => true,
              :templateids => template_id,
              :search => {
                :key_ => key
              }
            }
          }
          connection.query(request)
        end

        # Trigger descriptions are not unique, so to find a specific trigger we want
        # to search by description and expression
        def find_trigger_ids(connection, description, expression)
          request = {
            :method => 'trigger.get',
            :params => {
              :expandExpression => true,
              :search => {
                :description => description
              },
              :output => 'extend'
            }
          }
          triggers = connection.query(request)

          # Unfortunately we can't search by expression via the API, because in the
          # database its stored in a compacted format. But the :expandExpression
          # above caused expression to get exploded back to match the input form, so
          # we can filter by expression now.  We also ignore any trigger where
          # templateid is non-zero as those are *instances* of the "master" template
          # (referenced in the templateid) as applied to individual hosts and they
          # are not editable via the API

          result = []
          triggers.each do |trigger|
            next if trigger['expression'] != expression
            next if trigger['templateid'] != '0'
            result.push(trigger)
          end
          result
        end

        # Trigger descriptions are not unique, so to find a specific trigger we want
        # to search by description and expression
        def find_trigger_prototype_ids(connection, description, expression)
          request = {
            :method => 'triggerprototype.get',
            :params => {
              :expandExpression => true,
              :search => {
                :description => description
              },
              :output => 'extend'
            }
          }
          triggers = connection.query(request)

          # Unfortunately we can't search by expression via the API, because in the
          # database its stored in a compacted format. But the :expandExpression
          # above caused expression to get exploded back to match the input form, so
          # we can filter by expression now.  We also ignore any trigger where
          # templateid is non-zero as those are *instances* of the "master" template
          # (referenced in the templateid) as applied to individual hosts and they
          # are not editable via the API

          result = []
          triggers.each do |trigger|
            next if trigger['expression'] != expression
            next if trigger['templateid'] != '0'
            result.push(trigger)
          end
          result
        end

        def find_item_ids(connection, template_id, key, name = nil)
          request = {
            :method => 'item.get',
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

        def find_item_prototype_ids(connection, template_id, key, discovery_rule_id = nil)
          request = {
            :method => 'itemprototype.get',
            :params => {
              :templateids => template_id,
              :search => {
                :key_ => key
              }
            }
          }
          if discovery_rule_id
            request[:params][:discoveryids] = discovery_rule_id
          end
          connection.query(request)
        end

        def find_item_ids_on_host(connection, host, key)
          request = {
            :method => 'item.get',
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
            :method => 'graph.get',
            :params => {
              :filter => {
                :name => name
              }
            }
          }
          connection.query(request)
        end

        def find_graph_prototype_ids(connection, name)
          request = {
            :method => 'graphprototype.get',
            :params => {
              :filter => {
                :name => name
              }
            }
          }
          connection.query(request)
        end

        # get_* routines allow arbitrary searching of the existing Zabbix config
        # search_params should be a structure of parameters to pass to the Zabbix API
        # e.g. calling get_triggers with {"search" => { "description" => "something" } }
        # will find all triggers with "something" in the description field.  To
        # fetch all triggers provide nil or {}, but for large zabbix instances this
        # may overrun the PHP memory limits and fail.
        #
        # If your chef rules always add a unique string to the description of
        # triggers/items/etc you insert, then you can use this to find them and remove
        # them when your chef rules no longer specify to add them

        def get_triggers(connection, search_params)
          search_params = {} if search_params.nil?
          search_params[:output] = 'extend'
          search_params[:expandExpression] = true
          request = {
            :method => 'trigger.get',
            :params => search_params,
          }
          triggers = connection.query(request)
          if triggers.nil?
            Chef::Application.fatal! 'Could not retrieve existing trigger list'
          end

          # We ignore any trigger where templateid is non-zero as those are *instances*
          # of the template (referenced in the templateid) as applied to individual hosts
          # and they are not editable via the API
          triggers.reject { |t| t['templateid'] != '0' }
        end

        def get_hosts(connection, search_params)
          search_params = {} if search_params.nil?
          search_params[:output] = 'extend'
          request = {
            :method => 'host.get',
            :params => search_params
          }
          hosts = connection.query(request)
          if hosts.nil?
            Chef::Application.fatal! 'Could not retrieve existing host list'
          end

          hosts
        end

        def get_items(connection, search_params)
          search_params = {} if search_params.nil?
          search_params[:output] = 'extend'
          request = {
            :method => 'item.get',
            :params => search_params,
          }
          items = connection.query(request)
          if items.nil?
            Chef::Application.fatal! 'Could not retrieve existing item list'
          end

          items
        end

        def get_templates(connection, search_params)
          search_params = {} if search_params.nil?
          search_params[:output] = 'extend'
          request = {
            :method => 'template.get',
            :params => search_params
          }
          templates = connection.query(request)
          if templates.nil?
            Chef::Application.fatal! 'Could not retrieve existing template list'
          end

          templates
        end
      end
    end
  end
end
