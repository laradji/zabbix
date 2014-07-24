actions :create_or_update, :create, :update, :delete
default_action :create_or_update

attribute :name, :kind_of => String, :required => true

attribute :hsize, :kind_of => Integer, :default => 1
attribute :vsize, :kind_of => Integer, :default => 1

# This accepts an Array of Zabbix ScreenItem objects supplied as Ruby
# Hashes for the attributes of attached ScreenItem objects
#
# The `resourceid` is a special attribute, which can either be:
# - Fixnum: in that case that will be used in the Zabbix API as-is
# - Hash: containing the `:host` symbol as a key to indicate which
#   host machine's resources will we use, and also containing either of these:
#   - name: only valid when the `resourcetype` is 0, it will be used to get
#     the graph of the given host as a normal graph resource
#   - key_: only valid when the `resourcetype` is 1, it will identify the item
#     of the given host to use as a simple graph resource
# Please note: only `resourcetype` 0 and 1 lookups are supported currently
#
# Example:
# [{
# resourcetype: 1,
# colspan: 1,
# rowspan: 1,
# elements: 25,
# height: 200,
# resourceid: {host: 'Host Name', key_: 'system.cpu.load[percpu,avg1]'},
# width: 320,
# x: 1,
# y: 1
# },
# {
# resourcetype: 0,
# colspan: 1,
# rowspan: 1,
# elements: 25,
# height: 200,
# resourceid: {host: 'Host Name', name: 'CPU load'},
# width: 320,
# x: 1,
# y: 1
# },
# {
# resourcetype: 0
# colspan: 1,
# rowspan: 1,
# elements: 25,
# height: 200,
# resourceid: 581,
# width: 320,
# x: 1,
# y: 1
# }]
attribute :screen_items, :kind_of => Array, :default => []

# This is a Ruby Hash object with 3 required parameters used for connecting to
# the Zabbix server's API. An example could be this:
# { url: "https://zabbix.server.address.com/api_jsonrpc.php", user: 'Admin',
#   password: 'zabbix' }
attribute :server_connection, :kind_of => Hash, :default => {}
