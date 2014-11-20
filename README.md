[![Build Status](https://travis-ci.org/laradji/zabbix.png?branch=master)](https://travis-ci.org/laradji/zabbix)

# DESCRIPTION
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/laradji/zabbix?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This cookbook install zabbix-agent and zabbix-server.

By defaut the cookbook installs zabbix-agent, check the attribute for enable/disable zabbix_server / web or disable zabbix_agent installation.

Default login password for zabbix frontend is admin / zabbix  CHANGE IT !

# USAGE

Be careful when you update your server version, you need to run the sql patch in /opt/zabbix-$VERSION.

If you do not specify source\_url attributes for agent or server they will be set to download the specified
branch and version from the official Zabbix source repository. If you want to upgrade later, you need to
either nil out the source\_url attributes or set them to the url you wish to download from.

    node['zabbix']['agent']['source_url'] = nil
    node['zabbix']['server']['source_url'] = nil

Please include the default recipe before using any other recipe.

Installing the Agent :

    "recipe[zabbix]"

Installing the Server :

    "recipe[zabbix]",  
    "recipe[zabbix::server]"

Installing the Database :

    "recipe[mysql::server]",
    "recipe[zabbix]",
    "recipe[zabbix::database]"

Installing all 3 - Database MUST come before Server

    "recipe[database::mysql]",
    "recipe[mysql::server]",
    "recipe[zabbix]",
    "recipe[zabbix::database]",
    "recipe[zabbix::server]"

NOTE:

If you are running on Redhat, Centos, Scientific or Amazon, you will need packages from EPEL.
Include "recipe[yum::epel]" in your runlist or satisfy these requirements some other way.

    "recipe[yum::epel]"

# ATTRIBUTES

Don't forget to set :

    node.set['zabbix']['agent']['servers'] = ["Your_zabbix_server.com","secondaryserver.com"]
    node.set['zabbix']['web']['fqdn'] or you will not have the zabbix web interface

Note :

A Zabbix agent running on the Zabbix server will need to :

* use a different account than the on the server uses or it will be able to spy on private data.
* specify the local Zabbix server using the localhost (127.0.0.1, ::1) address.

example :

## Server

	  node.set['zabbix']['server']['branch'] = "ZABBIX%20Latest%20Stable"
	  node.set['zabbix']['server']['version'] = "2.0.0"
	  node.set['zabbix']['server']['source_url'] = nil
	  ndoe.set['zabbix']['server']['install_method'] = "source"

## Agent

	  node.set['zabbix']['agent']['branch'] = "ZABBIX%20Latest%20Stable"
	  node.set['zabbix']['agent']['version'] = "2.0.0"
	  node.set['zabbix']['agent']['source_url'] = nil
	  node.set['zabbix']['agent']['install_method'] = "prebuild"

## Database

    node.set['zabbix']['database']['install_method'] = 'mysql'
    node.set['zabbix']['database']['dbname'] = "zabbix"
    node.set['zabbix']['database']['dbuser'] = "zabbix"
    node.set['zabbix']['database']['dbhost'] = "localhost"
    node.set['zabbix']['database']['dbpassword'] = 'password'
    node.set['zabbix']['database']['dbport'] = "3306"

If you are using AWS RDS

    node.set['zabbix']['database']['install_method'] = 'rds_mysql'
    node.set['zabbix']['database']['rds_master_user'] = 'username'
    node.set['zabbix']['database']['rds_master_password'] = 'password'



# RECIPES

## default

The default recipe creates the Zabbix user and directories used by all Zabbix components.

Optionally, it installs the Zabbix agent.

You can control the agent install with the following attributes:

    node['zabbix']['agent']['install'] = true
    node['zabbix']['agent']['install_method'] = 'source'

## agent\_prebuild

Downloads and installs the Zabbix agent from a pre built package

If you are on a machine in the RHEL family of platforms, then you must have your
package manager setup to allow installation of:

    package "redhat-lsb"

You can control the agent version with:

    node['zabbix']['agent']['version']

## agent\_source

Downloads and installs the Zabbix agent from source

If you are on a machine in the RHEL family of platforms, then you will
need to install packages from the EPEL repository. The easiest way to do this
is to add the following recipe to your runlist before zabbix::agent\_source

    recipe "yum::epel"

You can control the agent install with:

    node['zabbix']['agent']['branch']
    node['zabbix']['agent']['version']
    node['zabbix']['agent']['configure_options']

## database

WARNING: This recipe persists your database credentials back to the Chef server
as plaintext  node attributes. To prevent this, consume the `zabbix_database`
LWRP in your own wrapper cookbook.

Creates and initializes the Zabbix database

Currenly only supports MySql and RDS MySql databases

If they are not already set, this recipe will generate the following attributes:

    node['zabbix']['database']['dbpassword']
    node['mysql']['server_root_password'] # Not generated if you are using RDS

You can control the database version with:

    node['zabbix']['server']['branch']
    node['zabbix']['server']['version']

The database setup uses the following attributes:

    node['zabbix']['database']['dbhost']
    node['zabbix']['database']['dbname']
    node['zabbix']['database']['dbuser']
    node['zabbix']['database']['dbpassword']

    node['zabbix']['database']['install_method']

If `install_method` is 'mysql' you also need:

    node['mysql']['server_root_password']

If `install_method` is 'rds\_mysql' you also need:

    node['zabbix']['database']['rds_master_username']
    node['zabbix']['database']['rds_master_password']

## firewall

Opens firewall rules to allow Zabbix nodes to communicate with each other.

## server

Delegates to other recipes to install the Zabbix server and Web components.

You can control the server and web installs with the following attributes:

    node['zabbix']['server']['install'] = true
    node['zabbix']['server']['install_method'] = 'source'
    node['zabbix']['web']['install'] = true

If you are using a MySql or RDS MySql database make sure your runlist
includes:

    "recipe[database::mysql]",
    "recipe[mysql::client]"

If you are user a Postgres database make sure your runlist includes:

    "recipe[database::postgresql]",
    "recipe[postgresql::client]",

## server\_source

Downloads and installs the Zabbix Server component from source

If you are on a machine in the RHEL family of platforms, then you will
need to install packages from the EPEL repository. The easiest way to do this
is to add the following recipe to your runlist before zabbix::server\_source

    recipe "yum::epel"

You can control the server install with:

    node['zabbix']['server']['branch']
    node['zabbix']['server']['version']
    node['zabbix']['server']['configure_options']

The server also needs to know about:

    node['zabbix']['database']['dbhost']
    node['zabbix']['database']['dbname']
    node['zabbix']['database']['dbuser']
    node['zabbix']['database']['dbpassword']
    node['zabbix']['database']['dbport']

## web

Creates an Apache site for the Zabbix Web component

# LWRPs

## database

### resources/database

Installs the Zabbix Database

The default provider is Chef::Provider::ZabbixDatabaseMySql in "providers/database_my_sql".
If you want a different provider, make sure you set the following in your resource call.

    provider Chef::Provider::SomeProviderClass

#### Actions

* `create` (Default Action) - Creates the Zabbix Database

#### Attributes

* `dbname` (Name Attribute) -  Name of the Zabbix databse to create
* `host` - Host to create the database on
* `port` - Port to connext to the database over
* `username` - Name of the Zabbix database user
* `password` - Password for the Zabbix database user
* `root_username` - Name of the root user for the database server
* `root_password` - Password for the database root user
* `allowed_user_hosts` (Default: '') - Where users can connect to the database from
* `server_branch` - Which branch of server code you are using
* `server_version` - Which version of server code you are using
* `source_dir` - Where Zabbix source code should be stored on the host
* `install_dir` - Where Zabbix should be installed to

### providers/database\_my\_sql

Installs a MySql or RDS MySql Zabbix Database

This is the default provider for `resources/database`

If you are using MySQL make sure you set

    root_username "root"
    root_password "your root password"

If you are using RDS MySql make sure you set

    root_username "your rds master username"
    root_password "your rds master password"

### providers/database\_postgres

Installs a Postgres Zabbix Database

Call the `zabbix_database` resource with

    provider Chef::Provider::ZabbixDatabasePostgres

Make sure you set

    root_username 'postgres'
    root_pasword  'your postgres admin password'

The `allowed_user_hosts` attribute is ignored

### resources/source

Fetchs the Zabbix source tar and does something with it

#### Actions
* `extract_only` (Default Action) - Just fetch and extract the tar
* `install_server` - Fetch the tar then compile the source as a Server
* `install_agent` - Fetch the tar then compile the source as an Agent

#### Attributes
* `name` (Name Attribute) - An arbitrary name for the resource
* `branch` - The branch of Zabbix to grab code for
* `version` - The version of Zabbix to grab code for
* `code_dir` - Where Zabbix source code should be stored on the host
* `target_dir` - A sub directory under `code_dir` where you want the source extracted
* `install_dir` (Optional) - Where Zabbix should be installed to
* `configure_options` (Optional) - Flags to use when compiling Zabbix

### providers/source:

Default implementation of how to Fetch and handle the Zabbix source code.


# TODO

* Support more platform on agent side windows ?
* LWRP Magic ?

# CHANGELOG

### 0.8.0
* This version is a big change with a lot of bugfix and change. Please be carefull if you are updated from previous version

### 0.0.42
* Adds Berkshelf/Vagrant 1.1 compatibility (andrewGarson)
  * Moves recipe[yum::epel] to a documented runlist dependency instead of forcing you to use it via include_recipe

### 0.0.41
  * Format metadata and add support for Oracle linux (Thanks to tas50 and his love for oracle Linux)
  * Fix about redhat LSB in agent-prebuild recipe (Thanks nutznboltz)
* Fix Add missing shabang for init file. (Thanks justinabrahms)
  * Fix FC045 foodcritic
  * new dependencies version on database and mysql cookbook
* Add support for custom config file location to zabbix_agentd.init-rh.erb (Thanks charlesjohnson)

### 0.0.40
  * Refactoring for passing foodcritic with help from dkarpenko
  * Added new attribute for server service : log_level
  * Added new attribute for server service : max_housekeeper_delete & housekeeping_frequency
  * Modified firewall recipe to accept connection to localhost zabbix_server

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
  * Added missing node['zabbix']['server']['dbport'] to templates/default/zabbix_web.conf.php.erb
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
