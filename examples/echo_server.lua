
local nn = require 'nanomsg-ffi'

local ADDRESS = "tcp://127.0.0.1:5556"

local rep = nn.socket( nn.REP )

print("...starting server loop...")
local echo
while echo ~= "EXIT" do
    local cid, err = rep:bind( ADDRESS )
    assert( cid, nn.strerror(err) )

    local msg, sz
    msg, err = rep:recv_zc()
    assert( msg, nn.strerror(err) )

    echo = msg:tostring()
    print( "GOT:", '"' .. echo .. '"' )

    sz, err = rep:send( echo, #echo ) -- TODO msg.ptr, msg.size )
    assert( sz > 0, nn.strerror(err) )

    rep:shutdown( cid )
end

print("...done...")

