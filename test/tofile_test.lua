local assert = require('assert')
local errno = require('errno')
local tofile = require('io.tofile')
local fileno = require('io.fileno')

local f = assert(io.tmpfile())
assert(f:write('hello'))
assert(f:flush())

-- test that wraps a fd to new lua file handle
local fd = fileno(f)
local newf = assert(tofile(fd, 'a+'))
assert.not_equal(fileno(newf), fd)
f:close()

-- test write a data
assert(newf:write(' world!'))
assert(newf:seek('set', 0))
assert.equal(newf:read('*a'), 'hello world!')
newf:close()

-- test that convert to file without mode argument
f = assert(io.tmpfile())
fd = fileno(f)
newf = assert(tofile(fd))
newf:close()

-- test that return error if fd is invalid
local err, eno
f, err, eno = tofile(-1)
assert.is_nil(f)
assert.is_string(err)
assert.equal_string(errno[eno], errno.EBADF)

-- test that return error if mode is invalid
f, err, eno = tofile(fd, 'hello')
assert.is_nil(f)
assert.is_string(err)
assert.equal_string(errno[eno], errno.EINVAL)

-- test that return error if io.tmpfile is not defined
package.loaded['io.tofile'] = nil
_G.io.tmpfile = nil
tofile = require('io.tofile')
f, err, eno = tofile(fd, 'hello')
assert.is_nil(f)
assert.is_string(err)
assert.equal_string(errno[eno], errno.ENOTSUP)
