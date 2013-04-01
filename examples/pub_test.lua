
local nn = require 'nanomsg-ffi'

local ADDRESS = 'tcp://127.0.0.1:5557'

if #arg ~= 2 then
    io.stdout:write('usage:  pub_test.lua channel1_name channel2_name\n\n')
    io.stdout:write('takes stdin and publishes it, alternating lines between\n')
    io.stdout:write('channel1_name and channel2_name\n')
    os.exit(-1)
end

local channels = { arg[1], arg[2] }

local pub, err = nn.socket( nn.PUB )
assert( pub, nn.strerror(err) )

local pid, err = pub:bind( ADDRESS )
assert( pid >= 0 , nn.strerror(err) )

print(string.format('...publisher started... with channels 1=%s, 2=%s',
		    channels[1], channels[2]))

local next_channel = 1
local line_count = 0
for line in io.lines() do
    local msg = channels[next_channel] .. '|' .. line
    next_channel = (next_channel == 1) and 2 or 1

    local rc, err = pub:send( msg, #msg )
    assert( rc > 0, 'send failed' )    
    line_count = line_count + 1
end

print(string.format('...publisher done..., sent %d lines', line_count))

