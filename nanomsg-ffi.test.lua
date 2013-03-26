local ffi = require "ffi"
local cwtest = require "cwtest"
local nn = require "nanomsg-ffi"
local T = cwtest.new()

T.posint = function(self,x)
  local r
  if (type(x) ~= "number") or (math.floor(x) ~= x) then
    r = self.fail_tpl(self, " (%s is not an integer)", tostring(x))
  elseif x >= 0 then
    r = self.pass_tpl(self, " (%d >= 0)", x)
  else
    r = self.fail_tpl(self, " (%d < 0)", x)
  end
  return r
end

T:start("REQ/REP re-sending of request"); do
  -- from tests/reqrep.c
  local ADDRESS = "inproc://a"
  local rep, req, err
  rep, err = nn.socket(nn.AF_SP, nn.REP)
  T:yes( rep )
  T:posint( rep:bind(ADDRESS) )
  req, err = nn.socket(nn.AF_SP, nn.REQ)
  T:yes( req )
  T:posint( req:connect(ADDRESS) )
  local resend_ivl = ffi.new("int[1]", 100)
  T:eq(
    req:setsockopt(nn.REQ, nn.REQ_RESEND_IVL, resend_ivl, ffi.sizeof("int")),
    0
  )
  local buf = ffi.new("char[32]")
  T:eq( req:send("ABC", 3, 0), 3 )
  T:eq( rep:recv(buf, ffi.sizeof(buf), 0), 3 )
  T:eq( rep:recv(buf, ffi.sizeof(buf), 0), 3 )
  T:eq( req:close(), 0 )
  T:eq( rep:close(), 0 )
end; T:done()

T:start("TCP close socket while not connected"); do
  -- from tests/tcp.c
  local ADDRESS = "tcp://127.0.0.1:5555"
  local sc, err = nn.socket(nn.AF_SP, nn.PAIR)
  T:yes( sc )
  T:posint( sc:connect(ADDRESS) )
  T:eq( sc:close(sc), 0 )
end; T:done()

T:start("TCP PAIR ping-pong"); do
  -- from tests/tcp.c
  local ADDRESS = "tcp://127.0.0.1:5555"
  local sc, sb, err
  sc, err = nn.socket(nn.AF_SP, nn.PAIR)
  T:yes( sc )
  T:posint( sc:connect(ADDRESS) )
  sb, err = nn.socket(nn.AF_SP, nn.PAIR)
  T:yes( sb )
  T:posint( sb:bind(ADDRESS) )
  local buf = ffi.new("char[32]")
  for i=1,10 do
    T:eq( sc:send("ABC", 3, 0), 3 )
    T:eq( sb:recv(buf, ffi.sizeof(buf), 0), 3 )
    T:eq( sb:send("DEF", 3, 0), 3 )
    T:eq( sc:recv(buf, ffi.sizeof(buf), 0), 3 )
  end
  T:eq( sc:close(), 0 )
  T:eq( sb:close(), 0 )
end; T:done()

T:start("TCP PAIR batch transfer"); do
  -- from tests/tcp.c
  local ADDRESS = "tcp://127.0.0.1:5555"
  local sc, sb, err
  sc, err = nn.socket(nn.AF_SP, nn.PAIR)
  T:yes( sc )
  T:posint( sc:connect(ADDRESS) )
  sb, err = nn.socket(nn.AF_SP, nn.PAIR)
  T:yes( sb )
  T:posint( sb:bind(ADDRESS) )
  local buf = ffi.new("char[32]")
  for i=1,10 do
    T:eq( sc:send("XYZ", 3, 0), 3 )
    T:eq( sb:recv(buf, ffi.sizeof(buf), 0), 3 )
  end
  T:eq( sc:close(), 0 )
  T:eq( sb:close(), 0 )
end; T:done()

T:start("TCP REQ/REP socket reuse"); do
  local ADDRESS = "tcp://127.0.0.1:5555"
  local req_buf, rep_buf = ffi.new("char[32]"), ffi.new("char[32]")
  local req, rep, err
  for i=1,10 do
    rep, err = nn.socket(nn.AF_SP, nn.REP)
    T:yes( rep )
    T:posint( rep:bind(ADDRESS) )
    req, err = nn.socket(nn.AF_SP, nn.REQ)
    T:yes( req )
    T:posint( req:connect(ADDRESS) )
    T:eq( req:send("REQ", 3, 0), 3 )
    T:eq( rep:recv(rep_buf, ffi.sizeof(rep_buf), 0), 3 )
    T:eq( rep:send("REP", 3, 0), 3 )
    T:eq( req:recv(req_buf, ffi.sizeof(req_buf), 0), 3 )
    T:eq( req:close(req), 0 )
    T:eq( rep:close(rep), 0 )
  end
end; T:done()
