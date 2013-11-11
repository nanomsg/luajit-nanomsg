-- Pair
-- Ported from: https://github.com/dysinger/nanomsg-examples

local usage = [[
USAGE:
  luajit pair.lua node0 <URL>
  luajit pair.lua node1 <URL> <MSG>
EXAMPLE:
  luajit pair.lua node0 ipc:///tmp/pair.ipc & node0=$!
  luajit pair.lua node1 ipc:///tmp/pair.ipc & node1=$!
  sleep 3
  kill $node0 $node1
]]

local nn = require "nanomsg-ffi"
local sleep = assert((require "socket").sleep)

local send_name = function(sock, name)
  print(string.format("%s: RECEIVED \"%s\"", name, name))
  sock:send(name, #name)
end

local recv_name = function(sock, name)
  local result = sock:recv_zc()
  if result then
    print(string.format("%s: RECEIVED \"%s\"", name, result:tostring()))
    result:free()
  end
end

local send_recv = function(sock, name)
  sock:setsockopt(nn.SOL_SOCKET, nn.RCVTIMEO, 100)
  while true do
    recv_name(sock, name)
    sleep(1)
    send_name(sock, name)
  end
end

local node0 = function(url)
  local sock, err = nn.socket( nn.PAIR )
  assert( sock, nn.strerror(err) )
  local _id, err = sock:bind( url )
  assert( _id, nn.strerror(err) )
  send_recv(sock, "node0")
  sock:shutdown(0)
end

local node1 = function(url)
  local sock, err = nn.socket( nn.PAIR )
  assert( sock, nn.strerror(err) )
  local _id, err = sock:connect( url )
  assert( _id, nn.strerror(err) )
  send_recv(sock, "node1")
  sock:shutdown(0)
end

if (arg[1] == "node0") and (#arg == 2) then
  node0(arg[2])
elseif (arg[1] == "node1") and (#arg == 2) then
  node1(arg[2])
else
  io.stderr:write(usage)
end
