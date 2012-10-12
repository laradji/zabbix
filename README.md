DESCRIPTION:
============

This cookbook install zabbix-agent and zabbix-server.

By defaut the cookbook install zabbix-agent, check the attribute for enable/disable zabbix_server / web or disable zabbix_agent installation.

Default login password for zabbix frontend is admin / zabbix  CHANGE IT !


REQUIREMENTS:
=============

Please include the default recipe before using any other recipe. 

Example :

"recipe[zabbix]",
"recipe[zabbix::agent_prebuild]"

OR

"recipe[zabbix]",
"recipe[zabbix::server_source]"


ATTRIBUTES:
===========

Don't forget to set :

	[:zabbix][:agent][:servers] = ["Your_zabbix_server.com","secondaryserver.com"]
	[:zabbix][:web][:fqdn] or you will not have the zabbix web interface

example : 

Server :
--------

	node[:zabbix][:server][:branch] = "ZABBIX%20Latest%20Stable"
	node[:zabbix][:server][:version] = "2.0.0"
	ndoe[:zabbix][:server][:install_method] = "source"

Agent :
-------

	node[:zabbix][:agent][:branch] = "ZABBIX%20Latest%20Stable"
	node[:zabbix][:agent][:version] = "2.0.0"
	node[:zabbix][:agent][:install_method] = "prebuild"

AWS RDS :
---------

Set this attribute with to use RDS for the Zabbix database. Default database remains localhost MySQL.

	node[:zabbix][:server][:db_install_method] = "rds_mysql"

These attributes must also be set. Values below are pre-defined.

	node[:zabbix][:server][:rds_master_user] = ""
	node[:zabbix][:server][:rds_master_password] = ""
	node[:zabbix][:server][:rds_dbhost] = ""
	node[:zabbix][:server][:rds_dbport] = "3306"
	node[:zabbix][:server][:rds_dbname] = "zabbix"
	node[:zabbix][:server][:rds_dbuser] = "zabbix"
	node[:zabbix][:server][:rds_dbpassword] = ""

USAGE :
=======

Be carefull when you update your server version, you need to run the sql patch in /opt/zabbix-$VERSION.

TODO :
======

* Support more platform on agent side windows ?
* LWRP Magic ?

CHANGELOG :
===========
### 0.0.39
	* Added zabbix bin patch in init script (deprecate change made in 0.0.38)
	* Changed default zabbix version to 2.0.3
	
### 0.0.38
	* Added zabbix_agent bin dir into PATH for Debian/Ubuntu (Some script need zabbix_sender)
	
### 0.0.37
	* Having run dir in /tmp is not so good (Guilhem Lettron)

### 0.0.36
	* added restart option to zabbix_agentd service definitions (Paul Rossman Patch)

### 0.0.35
	* Fix from Amiando about server_alias how should be a Array.
	* Fix from Guilhem about default run_dir be /tmp,it can be a big problem.

### 0.0.34
	* remove the protocol filter on firewall.

### 0.0.33
	* Added ServerActive configuration option for Zabbix agents (Paul Rossman Patch)
	
### 0.0.32
	* Fix a issue about order in the declaration of service and the template for recipes agent_*

### 0.0.31
	* Readme typo
	
### 0.0.30
	* Thanks to Paul Rossman for this release
	* Zabbix default install version is now 2.0.0
	* Option to install Zabbix database on RDS node (default remains localhost MySQL)
	* MySQL client now installed with Zabbix server
	* Added missing node[:zabbix][:server][:dbport] to templates/default/zabbix_web.conf.php.erb
	* Fixed recipe name typo in recipes/web.rb
	
### 0.0.29
	* Thanks to Steffen Gebert for this release
	* WARNING! this can break stuff : typo error on attribute file default['zabbix']['agent']['server'] -> default['zabbix']['agent']['servers']
	* Evaluate node.zabbix.agent.install as boolean, not as string
	* Respect src_dir in mysql_setup
	 
### 0.0.28
	* Thanks to Steffen Gebert for this release
	* Use generic sourceforge download URLs
	* Fix warning string literal in condition
	* Deploy zabbix.conf.php file for web frontend
	* Add "status" option to zabbix_server init script
	* Make MySQL populate scripts compatible with zabbix 2.0
	* Add example for Chef Solo usage to Vagrantfile
	
### 0.0.27
	* Configuration error about include_dir in zabbix_agentd.conf.erb	
	
###	0.0.26
	* zabbix agent and zabbix server don't want the same include_dir, be carefull if you use include_dir
	* noob error on zabbix::server
	
### 0.0.25
	* Don't try to use String as Interger !
	
### 0.0.24
	* Markdown Format for Readme.md
	
### 0.0.23
	* Some Foodcritic

### 0.0.22
    * Bug in metadata dependencies
    * Firewall does not fix the protocol anymore

### 0.0.21
	* Added Patch from Harlan Barnes <hbarnes@pobox.com> his patch include centos/redhat zabbix_server support.
	* Added Patch from Harlan Barnes <hbarnes@pobox.com> his patch include directory has attribute.
	* Force a minimum version for apache2 cookbook


### 0.0.20
    * Added Patch from Harlan Barnes <hbarnes@pobox.com> his patch include centos/redhat zabbix_agent support.

### 0.0.19
    * Fix README

### 0.0.18
	* Fix sysconfdir to point to /etc/zabbix on recipe server_source 
	* Fix right for folder frontends/php on recipe web
	* Hardcode the PATH of conf file in initscript
	* Agent source need to build on a other folder
	* Add --prefix option to default attributes when using *-source recipe
	
### 0.0.17
	* Don't mess with te PID, PID are now in /tmp
	
### 0.0.16 
	* Add depencies for recipe agent_source
	* Add AlertScriptsPath folder and option for server.
	
### 0.0.15
	* Add firewall magic for communication between client and server

### 0.0.14
	* Correction on documentation

### 0.0.13
	* Fix some issue on web receipe.
	
### 0.0.12 
	* Change default value of zabbix.server.dbpassword to nil

### 0.0.11
	* Remove mikoomo
	* Still refactoring
	
### 0.0.10
	* Preparation for multiple type installation and some refactoring
	* Support the installation of a beta version when using the install_method == source and changing the attribute branch

### 0.0.9
	* Tune of mikoomi for running on agent side.

### 0.0.8 
	* Fix some major issu
	
### 0.0.7 
	* Add some love to php value
	* Now recipe mysql_setup populate the database
	* Minor fix
	
### 0.0.6 
	* Change the name of the web_app to fit the fqdn
