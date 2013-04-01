
local ffi = require 'ffi'
local nn = require 'nanomsg-ffi'

local ADDRESS = "tcp://127.0.0.1:5556"

if #arg == 0 then
    io.stdout:write("usage:  echo_client.lua msg\n")
    os.exit(-1)
end

local echo_str = ''
for i, v in ipairs(arg) do
    echo_str = echo_str .. v
    if i ~= #arg then
        echo_str = echo_str .. ' '
    end
end

print( '...client started...' )

local req, err = nn.socket( nn.REQ )
assert( req, nn.strerror(err) )

local eid, err = req:connect( ADDRESS )
assert( eid, nn.strerror(err) )

local rc, err = req:send( echo_str, #echo_str )
assert( rc >= 0, nn.strerror(err) )

--TODO: local msg, err = req:recv_zc()
--assert( msg, nn.strerror(err) )
local buf = ffi.new("char [100]")
local sz, err = req:recv( buf, 100 )
assert( sz >= 0, nn.strerror(err) )

print( sz, ffi.string(buf,100) ) -- msg:tostring() )

print( '...client done...' )
