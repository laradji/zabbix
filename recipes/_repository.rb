# Copyright 2013, Ian Delahorne <ian.delahorne@gmail.com>
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

case node['platform']
when "ubuntu", "debian"
  apt_repository "zabbix" do 
    uri "http://repo.zabbix.com/zabbix/#{node[:zabbix][:major_version]}/#{node[:platform]}"
    distribution node['lsb']['codename']
    key "http://repo.zabbix.com/zabbix-official-repo.key"
    components ["main"]
  end
when "redhat","centos","scientific","oracle"
  include_recipe "yum::epel"
  yum_key "RPM-GPG-KEY-ZABBIX" do
    url "http://repo.zabbix.com/RPM-GPG-KEY-ZABBIX"
    action :add
  end
  yum_repository "zabbix" do
    repo_name "zabbix"
    description "Zabbix"
    key "RPM-GPG-KEY-ZABBIX"
    url "http://repo.zabbix.com/zabbix/#{node[:zabbix][:major_version]}/rhel/$releasever/$basearch"
    action :add
  end
end
