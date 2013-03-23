local ffi = require "ffi"
local cwtest = require "cwtest"
local nn = require "nanomsg-ffi"
local T = cwtest.new()

T.posint = function(self,x)
  if (type(x) ~= "number") or (math.floor(x) ~= x) then
    return self.fail_tpl(self, " (%s is not an integer)", tostring(x))
  elseif x >= 0 then
    return self.pass_tpl(self, " (%d >= 0)", x)
  else
    return self.fail_tpl(self, " (%d < 0)", x)
  end
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
end; T:done()
