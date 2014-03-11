actions :extract_only, :install_server, :install_agent
default_action :extract_only

attribute :source_url, :kind_of => String, :required => true

attribute :branch, :kind_of => String, :required => true
attribute :version, :kind_of => String, :required => true

attribute :code_dir, :kind_of => String, :required => true
attribute :target_dir, :kind_of => String, :required => true

attribute :install_dir, :kind_of => String, :default => ''
attribute :configure_options, :kind_of => String, :default => ''
