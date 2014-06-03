action :extract_only do
  tar_path = zabbix_tar_path(new_resource.code_dir, new_resource.branch, new_resource.version)

  if !::File.exist?(tar_path)
    Chef::Log.info("Zabbix tar: #{tar_path} does't exist")
    remote_file tar_path do
      source new_resource.source_url
      mode '0644'
      action :create
    end
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.info("Zabbix tar: #{tar_path} already exists")
  end

  extract_to = extract_dir(new_resource.code_dir, new_resource.target_dir)
  tmp_dir = ::File.join('/tmp', "zabbix-#{new_resource.version}")
  if !::File.exist?(extract_to)
    Chef::Log.info("Zabbix extract: #{extract_to} doesn't exist")
    script "extract Zabbix to #{extract_to}" do
      interpreter 'bash'
      user 'root'
      code <<-EOH
        rm -rf #{tmp_dir}
        tar xvfz #{tar_path} -C /tmp
        mv #{tmp_dir} #{extract_to}
      EOH

      not_if { ::File.exist?(extract_to) }
    end
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.info("Zabbix extract: #{extract_to} already exists")
  end
end

action :install_server do
  action_extract_only

  source_dir = extract_dir(new_resource.code_dir, new_resource.target_dir)
  unless ::File.exist?(::File.join(source_dir, 'already_built'))
    Chef::Log.info("Compiling Zabbix Server with options '#{new_resource.configure_options}")
    script "install_zabbix_server_#{zabbix_source_identifier(new_resource.branch, new_resource.version)}" do
      interpreter 'bash'
      user 'root'
      code <<-EOH
        (cd #{source_dir} && ./configure --enable-server --prefix=#{new_resource.install_dir} #{new_resource.configure_options})
        (cd #{source_dir} && make install && touch already_built)
      EOH
    end
    new_resource.updated_by_last_action(true)
  end
end

action :install_agent do
  action_extract_only

  source_dir = extract_dir(new_resource.code_dir, new_resource.target_dir)
  unless ::File.exist?(::File.join(source_dir, 'already_built'))
    Chef::Log.info("Compiling Zabbix Agent with options '#{new_resource.configure_options}")
    script "install_zabbix_agent_#{zabbix_source_identifier(new_resource.branch, new_resource.version)}" do
      interpreter 'bash'
      user 'root'
      code <<-EOH
      (cd #{source_dir} && ./configure --enable-agent --prefix=#{new_resource.install_dir} #{new_resource.configure_options})
      (cd #{source_dir} && make install && touch already_built)
      EOH
    end
    new_resource.updated_by_last_action(true)
  end
end

def load_current_resource
  run_context.include_recipe 'zabbix::_providers_common'
  require 'zabbixapi'
end

def zabbix_source_identifier(branch, version)
  "#{branch.gsub('%20', '-')}-#{version}"
end

def zabbix_tar_path(code_dir, branch, version)
  ::File.join(code_dir, "zabbix-#{zabbix_source_identifier(branch, version)}.tar.gz")
end

def extract_dir(code_dir, target_dir)
  ::File.join(code_dir, target_dir)
end
