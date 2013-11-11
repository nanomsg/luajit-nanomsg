-- Pipeline
-- Ported from: https://github.com/dysinger/nanomsg-examples

local usage = [[
USAGE:
  luajit pipeline.lua node0 <URL>
  luajit pipeline.lua node1 <URL> <MSG>
EXAMPLE:
  luajit pipeline.lua node0 'ipc:///tmp/pipeline.ipc' & node0=$! && sleep 1
  luajit pipeline.lua node1 'ipc:///tmp/pipeline.ipc' 'Hello, World!'
  luajit pipeline.lua node1 'ipc:///tmp/pipeline.ipc' 'Goodbye.'
  kill $node0
]]

local nn = require "nanomsg-ffi"

local node0 = function(url)
  local sock, err = nn.socket( nn.PULL )
  assert( sock, nn.strerror(err) )
  local cid, err = sock:bind( url )
  assert( cid, nn.strerror(err) )
  while true do
    local msg, err = sock:recv_zc()
    assert( msg, nn.strerror(err) )
    print(string.format("NODE0: RECEIVED \"%s\"", msg:tostring()))
    msg:free()
  end
end

local node1 = function(url, msg)
  local sock, err = nn.socket( nn.PUSH )
  assert( sock, nn.strerror(err) )
  local eid, err = sock:connect( url )
  assert( eid, nn.strerror(err) )
  print(string.format("NODE1: SENDING \"%s\"", msg))
  assert( sock:send( msg, #msg ) == #msg )
  sock:shutdown(0)
end

if (arg[1] == "node0") and (#arg == 2) then
  node0(arg[2])
elseif (arg[1] == "node1") and (#arg == 3) then
  node1(arg[2], arg[3])
else
  io.stderr:write(usage)
end
