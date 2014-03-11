actions :create
default_action :create

attribute :name, :kind_of => String, :required => true

attribute :width, :kind_of => Fixnum, :default => 900
attribute :height, :kind_of => Fixnum, :default  => 200
attribute :yaxismin, :kind_of => Float, :default => 0.000
attribute :yaxismax, :kind_of => Float, :default => 100.000
attribute :percent_left, :kind_of => Float, :default => 0.000
attribute :percent_right, :kind_of => Float, :default => 0.000

attribute :show_work_period, :kind_of => [TrueClass, FalseClass], :default => true
attribute :show_triggers, :kind_of => [TrueClass, FalseClass], :default => true
attribute :show_legend, :kind_of => [TrueClass, FalseClass], :default => true
attribute :show_3d, :kind_of => [TrueClass, FalseClass], :default => false

attribute :type, :kind_of => Zabbix::API::GraphType, :default => Zabbix::API::GraphType.normal
attribute :ymin_type, :kind_of => Zabbix::API::GraphAxisType, :default => Zabbix::API::GraphAxisType.calculated
attribute :ymax_type, :kind_of => Zabbix::API::GraphAxisType, :default => Zabbix::API::GraphAxisType.calculated
# TODO: eventually these will be strings that could be floats for GraphAxisType.fixed
# or could reference an item_id for GraphAxisType.item
attribute :ymin_item, :kind_of => Float, :default => 0.000
attribute :ymax_item, :kind_of => Float, :default => 0.000

attribute :graph_items, :kind_of => Array, :required => true

attribute :prototype, :kind_of => [TrueClass, FalseClass], :default => false
attribute :server_connection, :kind_of => Hash, :required => true
