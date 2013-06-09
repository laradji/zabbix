action :create do

  chef_gem "zabbixapi" do
    action :install
    version "~> 0.5.9"
  end

  require 'zabbixapi'

  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|

    new_resource.graph_items.each do |graph_item|
      if graph_item[:item_template].nil?
        template_id = Zabbix::API.find_template_ids(connection, graph_item[:item_template]).first['templateid']
        item_ids = Zabbix::API.find_item_ids(connection, template_id, graph_item[:item_key])
      else
        item_ids = Zabbix::API.find_item_ids_on_host(connection, host, graph_item[:item_key])
      end
      graph_item[:itemid] = item_ids.first['itemid']
    end

    graph_ids = Zabbix::API.find_graph_ids(connection, new_resource.name)

    params = {
      :name => new_resource.name,

      :width => new_resource.width,
      :height => new_resource.height,
      :yaxismin => new_resource.yaxismin,
      :yaxismax => new_resource.yaxismax,
      :percent_left => new_resource.percent_left,
      :percent_right => new_resource.percent_right,

      :show_work_period => new_resource.show_work_period ? '1' : '0',
      :show_triggers => new_resource.show_triggers ? '1' : '0',
      :show_legend => new_resource.show_legend ? '1' : '0',
      :show_3d => new_resource.show_3d ? '1' : '0',

      :type => new_resource.type.value,
      :ymin_type => new_resource.ymin_type.value,
      :ymax_type => new_resource.ymax_type.value,
      :ymin_item => new_resource.ymin_item.to_s,
      :ymax_item => new_resource.ymax_item.to_s,

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
