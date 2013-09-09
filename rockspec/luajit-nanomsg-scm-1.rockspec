package = "luajit-nanomsg"
version = "scm-1"

source = {
   url = "git://github.com/nanomsg/luajit-nanomsg.git",
}

description = {
   summary = "FFI-based nanomsg binding",
   detailed = [[
      luajit-nanomsg is a FFI-based binding
      for the nanomsg library
   ]],
   homepage = "http://github.com/nanomsg/luajit-nanomsg",
   license = "MIT/X11",
}

dependencies = {
   "lua >= 5.1", -- "luajit >= 2.0.0"
}

build = {
   type = "none",
   install = {
      lua = {
         ["nanomsg-ffi"] = "nanomsg-ffi.lua",
      },
   },
   copy_directories = {},
}
