action :create do

  chef_gem "zabbixapi" do
    action :install
    version "~> 0.5.9"
  end

  require 'zabbixapi'

  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    template_id = Zabbix::API.find_template_ids(connection, new_resource.template).first['templateid']

    new_resource.graph_items.each do |graph_item|
      item_ids = Zabbix::API.find_item_ids(connection, template_id, graph_item[:item_key])
      graph_item[:itemid] = item_ids.first['itemid']
    end

    graph_ids = Zabbix::API.find_graph_ids(connection, template_id, new_resource.name)

    params = {
      :name => new_resource.name,
      :show_triggers => new_resource.show_triggers ? '1' : '0',
      :width => new_resource.width,
      :height => new_resource.height,
      :gitems => new_resource.graph_items.map(&:to_hash)
    }
    method = 'graph.create'

    unless graph_ids.empty?
      method = 'graph.update'
      params[:graphid] = graph_ids.first['graphid']
    end

    connection.query({
      :method => method,
      :params => params
    })
  end
  new_resource.updated_by_last_action(true)
end
