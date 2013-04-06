def zabbix_source_identifier(branch, version)
  "#{branch.gsub("%20", "-")}-#{version}"
end

def zabbix_tar_path(code_dir, branch, version)
  ::File.join(code_dir, "zabbix-#{zabbix_source_identifier(branch, version)}.tar.gz")
end

def zabbix_source_url(branch, version)
  "http://downloads.sourceforge.net/project/zabbix/#{branch}/#{version}/zabbix-#{version}.tar.gz"
end

def extract_dir(code_dir, target_dir)
  ::File.join(code_dir, target_dir)
end

action :extract_only do
  tar_path = zabbix_tar_path(new_resource.code_dir, new_resource.branch, new_resource.version)
  source_url = zabbix_source_url(new_resource.branch, new_resource.version)
  remote_file tar_path do
    source source_url
    mode "0644"
    action :create_if_missing
  end

  extract_to = extract_dir(new_resource.code_dir, new_resource.target_dir)
  tmp_dir = ::File.join("/tmp", "zabbix-#{new_resource.version}")
  script "extract Zabbix to #{extract_to}" do
    interpreter "bash"
    user "root"
    code <<-EOH
      rm -rf #{tmp_dir}
      tar xvfz #{tar_path} -C /tmp
      mv #{tmp_dir} #{extract_to}
    EOH

    not_if { ::File.exists?(extract_to) }
  end
end

action :install_server do
  action_extract_only

  source_dir = extract_dir(new_resource.code_dir, new_resource.target_dir)
  script "install_zabbix_server_#{zabbix_source_identifier(new_resource.branch, new_resource.version)}" do
    interpreter "bash"
    user "root"
    code <<-EOH
      (cd #{source_dir} && ./configure --enable-server --prefix=#{new_resource.install_dir} #{new_resource.configure_options})
      (cd #{source_dir} && make install && touch already_built)
    EOH
    not_if { ::File.exists?(::File.join(source_dir, "already_built")) }
  end
end

action :install_agent do
  action_extract_only

  source_dir = extract_dir(new_resource.code_dir, new_resource.target_dir)
  script "install_zabbix_agent_#{zabbix_source_identifier(new_resource.branch, new_resource.version)}" do
    interpreter "bash"
    user "root"
    code <<-EOH
      (cd #{source_dir} && ./configure --enable-agent --prefix=#{new_resource.install_dir} #{new_resource.configure_options})
      (cd #{source_dir} && make install && touch already_built)
    EOH
    not_if { ::File.exists?(::File.join(source_dir, "already_built")) }
  end
end
