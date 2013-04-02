
-- listens for data on a nanomsg SUB using epoll,
-- and writes the data to stdout

local nn = require 'nanomsg-ffi'
local S = require 'syscall'

local SUB_ADDRESS = 'tcp://127.0.0.1:5557'

-- setup nanomsg SUB
local sub, sid, sub_fd, err, rc
sub, err = nn.socket( nn.SUB )
assert( sub, nn.strerror(err) )

sid, err = sub:connect( SUB_ADDRESS )
assert( sid >= 0, nn.strerror(err) )

rc, err = sub:setsockopt( nn.SUB, nn.SUB_SUBSCRIBE, '' )
assert( rc >= 0, nn.strerror(err) )

sub_fd, err = sub:getsockopt( nn.SOL_SOCKET, nn.RCVFD )
assert( sub_fd, nn.strerror(err) )


-- setup the epoll
local ep = S.epoll_create()
assert( ep, 'epoll_create failed' )
assert( ep:epoll_ctl('add', sub_fd, 'in') )

local maxevents = 1024
local events = S.t.epoll_events( maxevents )


-- run epoll loop
local terminated = false
while not terminated do
    local replies = ep:epoll_wait( events, maxevents )
    for _, event in ipairs(replies) do
        if event.fd == sub_fd then
            -- read from the nanomsg socket
            local msg, err = sub:recv_zc()
            if msg then
                io.stdout:write( msg:tostring(), '\n' )
            else
                io.stderr:write('SUB: error ', nnstrerror(err), '\n' )
            end
        else
            io.stderr:write('EPOLL: unknown fd: ', fd, '\n' )
        end
    end
end


