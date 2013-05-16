class Chef
  module Zabbix
    class << self
      def default_download_url(branch, version)
        "http://downloads.sourceforge.net/project/zabbix/#{branch}/#{version}/zabbix-#{version}.tar.gz"
      end
    end
  end
end
