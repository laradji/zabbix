actions :create_or_update, :create, :update, :delete
default_action :create_or_update

attribute :alias, :kind_of => String, :name_attribute => true, :required => true
attribute :password, :kind_of => String

attribute :first_name, :kind_of => String
attribute :surname, :kind_of => String

attribute :type, :kind_of => Integer, :default => 1

# This accepting an Array of Strings as the names of the user_groups to add
# the user to them
attribute :groups, :kind_of => Array, :default => []
# This is accepting an Array of Zabbix Media objects supplied as Ruby Hashes
# For the attributes of a Media object see:
# https://www.zabbix.com/documentation/2.2/manual/api/reference/usermedia/object#media
attribute :medias, :kind_of => Array, :default => []

attribute :create_missing_groups, :kind_of => [TrueClass, FalseClass], :default => false

# This attribute is used to force the update action even if the user object seems to be
# up-to-date, mostly used when we want to update the user's password, since the API
# get call does not return it (obviously), so it would never be updated otherwise
attribute :force_update, :kind_of => [TrueClass, FalseClass], :default => false

attribute :server_connection, :kind_of => Hash, :default => {}
