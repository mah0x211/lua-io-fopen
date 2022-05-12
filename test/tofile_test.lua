local assert = require('assert')
local errno = require('errno')
local errno_set = require('errno.set')
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
local err
f, err = tofile(-1)
assert.is_nil(f)
assert.equal(err.type, errno.EBADF)

-- test that return error if mode is invalid
f, err = tofile(fd, 'hello')
assert.is_nil(f)
assert.equal(err.type, errno.EINVAL)

-- test that return error if io.tmpfile function returns error
local tmpfile = io.tmpfile
_G.io.tmpfile = function()
    errno_set(errno.EMFILE.code)
    return nil, 'failed'
end
package.loaded['io.tofile'] = nil
tofile = require('io.tofile')
f, err = tofile(fd)
assert.is_nil(f)
assert.equal(err.type, errno.EMFILE)

-- test that throws an error if io.tmpfile function is not defined
_G.io.tmpfile = nil
package.loaded['io.tofile'] = nil
err = assert.throws(function()
    tofile = require('io.tofile')
end)
assert.match(err, '"io.tmpfile" function not found')

