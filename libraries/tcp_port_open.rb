require 'socket'
require 'timeout'
def port_open?(ip, port, seconds=1)
  begin
    TCPSocket.new(ip, port).close
      true
    rescue
      false
    end
end
