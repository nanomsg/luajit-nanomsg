local nn = require 'nanomsg-ffi'

local ADDRESS = 'tcp://127.0.0.1:5557'

if #arg ~= 1 then
    io.stdout:write('usage:  sub_test.lua channel_name\n')
    io.stdout:write('listens to publisher, subscribing to `channel_name`\n')
    os.exit(-1)
end

local sub, err = nn.socket( nn.SUB )
assert( sub, nn.strerror(err) )

local sid, err = sub:connect( ADDRESS )
assert( sid >= 0, nn.strerror(err) )

local rc, err = sub:setsockopt( nn.SUB, nn.SUB_SUBSCRIBE, arg[1] )
assert( rc >= 0, nn.strerror(err) )

print(string.format('...subscriber started... on channel %s\n', arg[1]))

local line_count = 0
while true do
    local msg, err = sub:recv_zc()
    if not msg then
        print(string.format("...stopping with code:%d err:%s\n",
			    err, nn.strerror(err)))
        break
    end

    print( msg:tostring() )
    line_count = line_count + 1
end

print(string.format('...subscriber done..., recv\'d %d lines\n', line_count))
