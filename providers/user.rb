action :create_or_update do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    get_user_request = {
      :method => 'user.get',
      :params => {
        :filter => {
          :alias => new_resource.alias
        }
      }
    }
    users = connection.query(get_user_request)

    if users.size == 0
      Chef::Log.info "Proceeding to create this user on the Zabbix server: '#{new_resource.alias}'"
      run_action :create
      new_resource.updated_by_last_action(true)
    else
      Chef::Log.debug "Going to update this user: '#{new_resource.alias}'"
      run_action :update
    end
  end
end

action :create do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|

    Chef::Application.fatal! "Please supply a password for creating this user: '#{new_resource.alias}'" if new_resource.password.nil? || new_resource.password.empty?

    groups = check_and_create_groups(new_resource, connection)

    request = {
      :method => 'user.create',
      :params => {
        :alias        => new_resource.alias,
        :passwd       => new_resource.password,
        :surname      => new_resource.surname,
        :name         => new_resource.first_name,
        :type         => new_resource.type,
        :usrgrps      => groups,
        :user_medias  => new_resource.medias
      }
    }
    Chef::Log.info "Creating new user: '#{new_resource.alias}'"
    connection.query(request)
  end
  new_resource.updated_by_last_action(true)
end

action :update do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|

    get_user_request = {
      :method => 'user.get',
      :params => {
        :filter => {
          :alias => new_resource.alias
        },
        :output => :extend,
        :selectUsrgrps => :shorten,
        :selectMedias => :extend
      }
    }
    user = connection.query(get_user_request).first
    if user.nil? || user.empty?
      Chef::Application.fatal! "Could not find user for update: '#{new_resource.alias}'"
    end

    groups = check_and_create_groups(new_resource, connection, true)

    need_to_update = false

    groups.each do |group|
      need_to_update = true if user['usrgrps'].select { |usergrp| usergrp['usrgrpid'] == group['usrgrpid'] }.empty?
    end
    { 'alias' => 'alias', 'first_name' => 'name', 'surname' => 'surname', 'type' => 'type', 'medias' => 'medias' }.each do |resource_attr_name, api_attr_name|
      if resource_attr_name != 'type'
        need_to_update = true if user[api_attr_name] != new_resource.send(resource_attr_name)
      else
        need_to_update = true if user[api_attr_name] != new_resource.send(resource_attr_name).to_s
      end
    end

    need_to_update = true if new_resource.force_update

    if need_to_update
      user_update_request = {
        :method => 'user.update',
        :params => {
          :userid       => user['userid'],
          :alias        => new_resource.alias,
          :passwd       => new_resource.password,
          :surname      => new_resource.surname,
          :name         => new_resource.first_name,
          :type         => new_resource.type,
          :usrgrps      => groups,
          :user_medias  => new_resource.medias
        }
      }
      Chef::Log.info "Updating user '#{new_resource.alias}'"
      connection.query(user_update_request)
      new_resource.updated_by_last_action(true)
    else
      Chef::Log.info "The attributes of user '#{new_resource.alias}' are already up-to-date, doing nothing"
    end

  end
end

action :delete do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|

    get_user_request = {
      :method => 'user.get',
      :params => {
        :filter => {
          :alias => new_resource.alias
        },
      }
    }
    user = connection.query(get_user_request).first
    if user.nil? || user.empty?
      Chef::Application.fatal! "Could not find user for delete: '#{new_resource.alias}'"
    end

    user_delete_request = {
      :method => 'user.delete',
      :params => [
        user['userid']
      ]
    }
    Chef::Log.info "Deleting user '#{new_resource.alias}'"
    result = connection.query(user_delete_request)
    Application.fatal! "Error deleting user '#{new_resource.alias}', see Chef errors" if result.nil? || result.empty? || result['userids'].nil? || result['userids'].empty? || !result['userids'].include?(user['userid'])
    new_resource.updated_by_last_action(true)
  end
end

def load_current_resource
  run_context.include_recipe 'zabbix::_providers_common'
  require 'zabbixapi'
end

def check_and_create_groups(new_resource, connection, extended_results = false)
  groups = []
  new_resource.groups.each do |current_user_group|
    Chef::Log.info "Checking for existence of group '#{current_user_group}'"
    get_user_group_request = {
      :method => 'usergroup.get',
      :params => {
        :filter => {
          :name => current_user_group
        }
      }
    }
    get_user_group_request[:params][:output] = :extend if extended_results
    group = connection.query(get_user_group_request)
    groups << evaluate_group_creation(group, current_user_group, connection, new_resource.create_missing_groups)
  end
  groups
end

def evaluate_group_creation(current_user_group_from_get, current_user_group_from_resource, connection, create_missing_groups)
  if current_user_group_from_get.length == 0 && create_missing_groups
    Chef::Log.info "Creating user group '#{current_user_group_from_resource}'"
    make_user_group_request = {
      :method => 'usergroup.create',
      :params => {
        :name => current_user_group_from_resource
      }
    }
    result = connection.query(make_user_group_request)
    Chef::Log.error("Error creating group '#{current_user_group_from_resource}', see Chef errors") if result.nil? || result.empty?
    # And now fetch the newly made user group to be sure it worked
    # and for later use
    connection.query(get_user_group_request).first
  elsif current_user_group_from_get.length == 1
    Chef::Log.info "Group '#{current_user_group_from_resource}' already exists"
    current_user_group_from_get.first
  else
    Chef::Application.fatal! "Could not find user group '#{current_user_group_from_resource}' for user '#{new_resource.alias}' and \"create_missing_groups\" is False (or unset)"
  end
end
