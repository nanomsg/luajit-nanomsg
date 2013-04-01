About
=====

This is a LuaJIT FFI-based binding to the [nanomsg library](http://nanomsg.org).

It exposes the raw API, as well as a higher-level convenience layer.


Installation
============

Simply put [nanomsg-ffi.lua](https://github.com/neomantra/luajit-nanomsg/blob/master/nanomsg-ffi.lua)
somewhere on your `LUA_PATH` and make sure that the [nanomsg](https://github.com/250bpm/nanomsg)
shared library is available on your `LD_LIBRARY_PATH`.


Usage
=====

```lua
local nn = require 'nanomsg-ffi'

-- nn.C exposes all of the nanomsg C API functions
print( nn.C.nn_errno() )

-- But there is a friendlier API available directly from nn:
print( nn.errno() )
print( nn.EAGAIN )

-- For convenience, names for errno's are available in nn.E
assert( nn.E[ nn.EAGAIN ] == 'EAGAIN' )

-- Use the nn.socket class rather than the functions in nn.C
local req, id, rc, err

req, err = nn.socket( onn.REQ )
assert( req, nn.strerror(err) )

id, err = req:connect( "tcp://127.0.0.1:555" )
assert( id, nn.strerror(err) )

local msg = "hello world"
rc, err = req:send( msg, #msg )
assert( rc > 0, nn.strerror(err) )

```

Socket object
=============

Socket is nanomsg's primary object.  Socket object can instantiated with `nn.socket( protocol, options)`, where `protocol` is the nanomsg enum, such as `nn.SUB`, and `options` is a table with the following optional fields:

 * `close_on_gc`:  Default is true.  When true, the socket's `close` method will be invoked upon garbage collection.  `close` may block, say one may to wish to invoke it manually at a determined time.

 * `domain`:  Default is `nn.AF_SP`.  The domain of the socket.  Options are `nn.AF_SP` and `nn.AF_SP_RAW`.


TODO: generate LDoc documentation and link to it



Running the test suite
======================

Test require [cwtest](https://github.com/catwell/cwtest). Either install it on your
system or just put [cwtest.lua](https://github.com/catwell/cwtest/blob/master/cwtest.lua)
somewhere on your LUA_PATH, then run `make test`.


Other nanomsg Lua Bindings 
==========================

If you are looking for a nanomsg binding that can work with plain Lua,
as well as LuaJIT, check out [lua-nanomsg](https://github.com/Neopallium/lua-nanomsg).


Roadmap
=======

This is usable now.   The future holds:

 * more documentation
 * more examples and performance tests
 * more hand-holding classes for nanomsg concepts
 * bind nn_sendmsg and nn_recvmsg and associated control structures


License
=======

```
Copyright (c) 2013 Evan Wies <evan at neomantra dot net>
 
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom
the Software is furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
IN THE SOFTWARE.
```
