define :zabbix_mysql_setup, :mysql_connection_info => nil do

  # @param [Hash] mysql_connection_info options to connect to MySql
  # @option mysql_connection_info [String] :host (nil) The Host - REQUIRED
  # @option mysql_connection_info [String] :dbname (nil) The Database Name - REQUIRED
  # @option mysql_connection_info [String] :username (nil) The Username - REQUIRED
  # @option mysql_connection_info [String] :password (nil) The Password - REQUIRED
  #
  # @raise [Chef::Zabbix::InvalidMySqlConnectionInfoError] if the connection info is bad
  #
  # @return [Hash] The mysql_connection_info hash if it's good
  def validate_mysql_connection_info(mysql_connection_info)
    bad = mysql_connection_info.nil?
    bad ||= !mysql_connection_info.is_a?(Hash)
    [:host, :dbname, :username, :password].each do |key|
      bad ||= mysql_connection_info[key].to_s.empty?
    end

    raise Chef::Zabbix::InvalidMySqlConnectionInfoError.new(mysql_connection_info) if bad

    mysql_connection_info
  end

  validate_mysql_connection_info(params[:mysql_connection_info])

  mysql_connection_info = params[:mysql_connection_info]
  mysql_root_connection = { 
    :host => mysql_connection_info[:host],
    :username => "root",
    :password => mysql_connection_info[:root_password]
  }

  include_recipe "database::mysql"

  # create zabbix database
  mysql_database mysql_connection_info[:dbname] do
    connection mysql_root_connection
    action :create
    notifies :run, "execute[zabbix_populate_schema]", :immediately
    notifies :run, "execute[zabbix_populate_image]", :immediately
    notifies :run, "execute[zabbix_populate_data]", :immediately
    notifies :create, "template[#{node['zabbix']['etc_dir']}/zabbix_server.conf]", :immediately
    notifies :create, "mysql_database_user[#{mysql_connection_info[:username]}]", :immediately
    notifies :grant, "mysql_database_user[#{mysql_connection_info[:username]}]", :immediately
    notifies :restart, "service[zabbix_server]", :immediately
  end

  # populate database
  if node['zabbix']['server']['version'].to_f < 2.0
    Chef::Log.info "Version 1.x branch of zabbix in use"
    execute "zabbix_populate_schema" do
      command "/usr/bin/mysql -u root #{mysql_connection_info[:dbname]} -p#{mysql_connection_info[:root_password]} < #{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/create/schema/mysql.sql"
      action :nothing
    end
    execute "zabbix_populate_data" do
      command "/usr/bin/mysql -u root #{mysql_connection_info[:dbname]} -p#{mysql_connection_info[:root_password]} < #{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/create/data/data.sql"
      action :nothing
    end
    execute "zabbix_populate_image" do
      command "/usr/bin/mysql -u root #{mysql_connection_info[:dbname]} -p#{mysql_connection_info[:root_password]} < #{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/create/data/images_mysql.sql"
      action :nothing
    end
  else
    Chef::Log.info "Version 2.x branch of zabbix in use"
    execute "zabbix_populate_schema" do
      command "/usr/bin/mysql -u root #{mysql_connection_info[:dbname]} -p#{mysql_connection_info[:root_password]} < #{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/database/mysql/schema.sql"
      action :nothing
    end
    execute "zabbix_populate_image" do
      command "/usr/bin/mysql -u root #{mysql_connection_info[:dbname]} -p#{mysql_connection_info[:root_password]} < #{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/database/mysql/images.sql"
      action :nothing
    end
    execute "zabbix_populate_data" do
      command "/usr/bin/mysql -u root #{mysql_connection_info[:dbname]} -p#{mysql_connection_info[:root_password]} < #{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/database/mysql/data.sql"
      action :nothing
    end
  end

  # create and grant zabbix user
  mysql_database_user mysql_connection_info[:username] do
    connection mysql_root_connection
    password mysql_connection_info[:password]
    database_name mysql_connection_info[:dbname]
    host 'localhost'
    privileges [:select,:update,:insert,:create,:drop,:delete]
    action :nothing
  end
end
