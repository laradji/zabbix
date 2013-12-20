include_recipe "zabbix::common"

# Install nginx and disable default site
node.override['nginx']['default_site_enabled'] = false
node.override['php-fpm']['pool']['www']['listen'] = node['zabbix']['web']['php']['fastcgi_listen']
include_recipe "nginx"


if node['zabbix']['web']['install_package']
  include_recipe "zabbix::_repository"

  case node['platform_family']
  when "debian"
    package "zabbix-frontend-php" do
      action :install
    end
    case node['zabbix']['database']['install_method']
    when "mysql"
      package "php5-mysql" do
        action :install
      end
    when "postgres"
      package "php5-pgsql" do
        action :install
      end
    end
  when "rhel"
    
    engine = case node['zabbix']['database']['install_method']
             when "mysql"
               "-mysql"
             when "postgres"
               "-pgsql"
             else
               ""
             end

    package "zabbix-web#{engine}" do
      action :install
    end
  end
  conf_dir = "/etc/zabbix/web"
  
else
  case node['platform_family']
  when "debian"
    %w{ php5-mysql php5-gd }.each do |pck|
      package pck do
        action :install
        notifies :restart, "service[nginx]"
      end
    end
  when "rhel"
    if node['platform_version'].to_f < 6.0
      %w{ php53-mysql php53-gd php53-bcmath php53-mbstring }.each do |pck|
        package pck do
          action :install
          notifies :restart, "service[nginx]"
        end
      end
    else
      %w{ php-mysql php-gd php-bcmath php-mbstring }.each do |pck|
        package pck do
          action :install
          notifies :restart, "service[nginx]"
        end
      end
    end
  end

  zabbix_source "extract_zabbix_web" do
    branch              node['zabbix']['server']['branch']
    version             node['zabbix']['server']['version']
    source_url          node['zabbix']['server']['source_url']
    code_dir            node['zabbix']['src_dir']
    target_dir          "zabbix-#{node['zabbix']['server']['version']}"  
    install_dir         node['zabbix']['install_dir']
    
    action :extract_only

  end

  # Link to the web interface version
  link node['zabbix']['web_dir'] do
    to "#{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/frontends/php"
  end

  conf_dir = ::File.join(node['zabbix']['src_dir'], "zabbix-#{node['zabbix']['server']['version']}", "frontends", "php", "conf") 
  directory conf_dir do
    owner node['nginx']['user']
    group node['nginx']['group']
    mode "0755"
    action :create
  end
end

#include_recipe "php-fpm"

# install zabbix PHP config file
template ::File.join(conf_dir, "zabbix.conf.php") do
  source "zabbix_web.conf.php.erb"
  owner "root"
  group "root"
  mode "754"
  variables ({
    :database => node['zabbix']['database'],
    :server => node['zabbix']['server']
  })
  notifies :restart, "service[php-fpm]", :delayed
end

# install host for zabbix
template "/etc/nginx/sites-available/zabbix" do
  source "zabbix_nginx.erb"
  owner "root"
  group "root"
  mode "754"
  variables ({
    :server_name => node['zabbix']['web']['fqdn'],
    :php_settings => node['zabbix']['web']['php']['settings'],
    :web_port => node['zabbix']['web']['port'],
    :web_dir => node['zabbix']['web_dir'],
    :fastcgi_listen => node['zabbix']['web']['php']['fastcgi_listen']
  })
  notifies :reload, "service[nginx]"
end

php_fpm_pool "zabbix" do
  listen node['zabbix']['web']['php']['fastcgi_listen']
end

nginx_site "zabbix"
