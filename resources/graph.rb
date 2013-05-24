actions :create
default_action :create

attribute :name, :kind_of => String, :required => true
attribute :template, :kind_of => String, :required => true
attribute :show_triggers, :kind_of => [TrueClass, FalseClass], :default => false
attribute :width, :kind_of => Fixnum, :required => true
attribute :height, :kind_of => Fixnum, :required => true
attribute :graph_items, :kind_of => Array, :required => true

attribute :server_connection, :kind_of => Hash, :required => true
