-- Request/Reply
-- Ported from: https://github.com/dysinger/nanomsg-examples

local usage = [[
USAGE:
  luajit reqrep.lua node0 <URL>
  luajit reqrep.lua node1 <URL>
EXAMPLE:
  luajit reqrep.lua node0 'ipc:///tmp/reqrep.ipc' & node0=$! && sleep 1
  luajit reqrep.lua node1 'ipc:///tmp/reqrep.ipc'
  kill $node0
]]

local nn = require "nanomsg-ffi"

local node0 = function(url)
  local sock, err = nn.socket( nn.REP )
  assert( sock, nn.strerror(err) )
  local cid, err = sock:bind( url )
  assert( cid, nn.strerror(err) )
  while true do
    local msg, err = sock:recv_zc()
    assert( msg, nn.strerror(err) )
    if msg:tostring():sub(1,4) == "DATE" then
      print("NODE0: RECEIVED DATE REQUEST")
      local d = os.date("%c")
      print(string.format("NODE0: SENDING DATE %s", d))
      assert( sock:send( d, #d ) == #d )
    end
    msg:free()
  end
end

local node1 = function(url)
  local DATE = "DATE"
  local sock, err = nn.socket( nn.REQ )
  assert( sock, nn.strerror(err) )
  local eid, err = sock:connect( url )
  assert( eid, nn.strerror(err) )
  print(string.format("NODE1: SENDING DATE REQUEST %s", DATE))
  assert( sock:send( DATE, #DATE ) == #DATE )
  local msg, err = sock:recv_zc()
  print(string.format("NODE1: RECEIVED DATE %s", msg:tostring()))
  msg:free()
  sock:shutdown(0)
end

if (arg[1] == "node0") and (#arg == 2) then
  node0(arg[2])
elseif (arg[1] == "node1") and (#arg == 2) then
  node1(arg[2])
else
  io.stderr:write(usage)
end
