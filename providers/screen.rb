action :create_or_update do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    get_screen_request = {
      :method => 'screen.get',
      :params => {
        :filter => {
          :name => new_resource.name
        }
      }
    }
    screens = connection.query(get_screen_request)

    if screens.size == 0
      Chef::Log.info "Screen does not exists. Proceeding to create this screen on the Zabbix server: '#{new_resource.name}'"
      run_action :create
      new_resource.updated_by_last_action(true)
    else
      Chef::Log.info "Going to update this screen (if needed): '#{new_resource.name}'"
      run_action :update
    end
  end
end

action :create do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|

    looked_up_screen_items = add_resource_ids_for_screen_items(new_resource.screen_items, connection)

    request = {
      :method => 'screen.create',
      :params => {
        :name  => new_resource.name,
        :hsize => new_resource.hsize,
        :vsize => new_resource.vsize,
        :screenitems => looked_up_screen_items
      }
    }
    Chef::Log.info "Creating new screen: '#{new_resource.name}'"
    connection.query(request)
  end
  new_resource.updated_by_last_action(true)
end

action :update do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|

    get_screen_request = {
      :method => 'screen.get',
      :params => {
        :filter => {
          :name => new_resource.name
        },
        :output => :extend,
        :selectScreenItems => :extend
      }
    }
    screen = connection.query(get_screen_request)
    if screen.nil? || screen.empty?
      Chef::Application.fatal! "Could not find screen for update: '#{new_resource.name}'"
    else
      screen = screen.first
    end

    looked_up_screen_items = add_resource_ids_for_screen_items(new_resource.screen_items, connection)

    need_to_update = false

    %w(name vsize hsize).each do |attr_name|
      need_to_update = true if screen[attr_name] != new_resource.send(attr_name).to_s
    end

    # We sort both of the arrays to make sure we can compare their elements
    # one by one
    screen['screenitems'].sort_by! { |hsh| hsh['resourceid'] }
    looked_up_screen_items.sort_by! { |hsh| hsh[:resourceid] }

    looked_up_screen_items.each_with_index do |screen_item, index|
      screen_item.each do |key, value|
        need_to_update = true if screen['screenitems'][index].nil? || value.to_s != screen['screenitems'][index][key.to_s]
      end
    end

    if need_to_update
      screen_update_request = {
        :method => 'screen.update',
        :params => {
          :screenid    => screen['screenid'],
          :name        => new_resource.name,
          :hsize       => new_resource.hsize,
          :vsize       => new_resource.vsize,
          :screenitems => looked_up_screen_items
        }
      }
      Chef::Log.info "Updating screen '#{new_resource.name}'"
      connection.query(screen_update_request)
      new_resource.updated_by_last_action(true)
    else
      Chef::Log.info "The attributes of screen '#{new_resource.name}' are already up-to-date, doing nothing"
    end

  end
end

action :delete do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|

    get_screen_request = {
      :method => 'screen.get',
      :params => {
        :filter => {
          :name => new_resource.name
        },
        :output => :shorten
      }
    }
    screen = connection.query(get_screen_request)
    if screen.nil? || screen.empty?
      Chef::Application.fatal! "Could not find screen for deletion: '#{new_resource.name}'"
    else
      screen = screen.first
    end

    screen_delete_request = {
      :method => 'screen.delete',
      :params => [
        screen['screenid']
      ]
    }
    Chef::Log.info "Deleting screen '#{new_resource.name}'"
    result = connection.query(screen_delete_request)
    Application.fatal! "Error deleting screen '#{new_resource.name}', see Chef errors" if result.nil? || result.empty? || result['screenids'].nil? || result['screenids'].empty? || !result['screenids'].include?(screen['screenid'])
    new_resource.updated_by_last_action(true)
  end
end

def load_current_resource
  run_context.include_recipe 'zabbix::_providers_common'
  require 'zabbixapi'
end

def add_resource_ids_for_screen_items(screen_items, connection)
  returned_screen_items = []
  screen_items.each do |current_screen_item|
    if current_screen_item[:resourceid].kind_of? Fixnum
      # We make it to a String for possible later comparison/sorting, because the API
      # can only return String values anyway
      current_screen_item[:resourceid] = current_screen_item[:resourceid].to_s
      returned_screen_items.push current_screen_item
    else
      if current_screen_item[:resourcetype] == 0
        Chef::Application.fatal! "When 'resourcetype' is 0 and 'resourceid' is a Hash, then you must set 'name' in that Hash" if current_screen_item[:resourceid][:name].nil?
        Chef::Log.debug "Checking graph id for: host: '#{current_screen_item[:resourceid][:host]}', name: '#{current_screen_item[:resourceid][:name]}'"
        current_screen_item[:resourceid] = get_graph_id_from_graph_name(current_screen_item[:resourceid][:host], current_screen_item[:resourceid][:name], connection)
      elsif current_screen_item[:resourcetype] == 1 || current_screen_item[:resourcetype] == 3
        Chef::Application.fatal! "When 'resourcetype' is 1 or 3 and 'resourceid' is a Hash, then you must set 'key_' in that Hash" if current_screen_item[:resourceid][:key_].nil?
        Chef::Log.debug "Checking item id for: host: '#{current_screen_item[:resourceid][:host]}', key: '#{current_screen_item[:resourceid][:key_]}'"
        current_screen_item[:resourceid] = get_item_id_from_item_key(current_screen_item[:resourceid][:host], current_screen_item[:resourceid][:key_], connection)
      end
      returned_screen_items.push current_screen_item
    end
  end
  returned_screen_items
end

def get_graph_id_from_graph_name(host_name, name, connection)
  return_id = nil
  get_graph_id_request = {
    :method => 'host.get',
    :params => {
      :selectGraphs => ['graphid', 'name'],
      :output => :shorten,
      :filter => {
        :host => host_name
      }
    }
  }
  graph_id_result = connection.query(get_graph_id_request)
  Chef::Application.fatal! "Could not find graphs at all for host: '#{host_name}'" if graph_id_result.nil? || graph_id_result.empty?
  graph_id_result.first['graphs'].each do |graph|
    return_id = graph['graphid'] if graph['name'] == name
  end
  Chef::Application.fatal! "Could not find graph id for host: '#{host_name}', name: '#{name}'" if return_id.nil?
  return_id
end

def get_item_id_from_item_key(host_name, key_, connection)
  return_id = nil
  get_item_id_request = {
    :method => 'host.get',
    :params => {
      :selectItems => ['itemid', 'key_'],
      :output => :shorten,
      :filter => {
        :host => host_name
      }
    }
  }
  item_id_result = connection.query(get_item_id_request)
  Chef::Application.fatal! "Could not find items at all for host: '#{host_name}'" if item_id_result.nil? || item_id_result.empty?
  item_id_result.first['items'].each do |item|
    return_id = item['itemid'] if item['key_'] == key_
  end
  Chef::Application.fatal! "Could not find item id for host: '#{host_name}', key_: '#{key_}'" if return_id.nil?
  return_id
end
