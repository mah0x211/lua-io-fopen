local assert = require('assert')
local errno = require('errno')
local errno_set = require('errno.set')
local fopen = require('io.fopen')
local fileno = require('io.fileno')

local testfuncs = {}
local testcase = setmetatable({}, {
    __newindex = function(_, name, func)
        if testfuncs[name] then
            error(string.format('testcase.%s is already defined', name), 2)
        end
        testfuncs[name] = true
        testfuncs[#testfuncs + 1] = {
            name = name,
            func = func,
        }
    end,
})

function testcase.fd_to_file()
    local f = assert(io.tmpfile())
    assert(f:write('hello'))
    assert(f:flush())

    -- test that wraps a fd to new lua file handle
    local fd = fileno(f)
    local newf = assert(fopen(fd, 'a+'))
    assert.not_equal(fileno(newf), fd)
    f:close()

    -- confirm that data can be written
    assert(newf:write(' world!'))
    assert(newf:seek('set', 0))
    assert.equal(newf:read('*a'), 'hello world!')
    newf:close()
end

function testcase.fd_to_file_without_mode()
    -- test that convert to file without mode argument
    local f = assert(io.tmpfile())
    local fd = fileno(f)
    local newf = assert(fopen(fd))

    -- confirm that data cannot be written
    assert(not newf:write(' world!'))
    newf:close()
end

function testcase.pathname_to_file()
    local f = assert(io.open('test/example.txt', 'w+'))
    assert(f:write('hello'))
    f:close()

    -- test that open a file
    f = assert(fopen('test/example.txt', 'a+'))
    -- confirm that data can be written
    assert(f:write(' world!'))
    assert(f:seek('set', 0))
    assert.equal(f:read('*a'), 'hello world!')
    f:close()
end

function testcase.pathname_to_file_without_mode()
    local f = assert(io.open('test/example.txt', 'w+'))
    assert(f:write('hello'))
    f:close()

    -- test that open a file
    f = assert(fopen('test/example.txt'))
    -- confirm that data cannot be written
    assert(not f:write(' world!'))
    f:close()
end

function testcase.invalid_fd()
    -- test that return error if fd is invalid
    local f, err = fopen(-1)
    assert.is_nil(f)
    assert.equal(err.type, errno.EBADF)

    -- test that return error if not file fd
    f = assert(io.open('test/'))
    f, err = fopen(fileno(f))
    assert.is_nil(f)
    assert.equal(err.type, errno.EINVAL)
end

function testcase.invalid_pathname()
    -- test that return error if pathname of file is not a file
    local f, err = fopen('test/')
    assert.is_nil(f)
    assert.equal(err.type, errno.ENOENT)
end

function testcase.invalid_mode()
    -- test that return error if mode is invalid
    local f, err = fopen(1, 'hello')
    assert.is_nil(f)
    assert.equal(err.type, errno.EINVAL)
end

function testcase.error_from_io_tmpfile()
    local tmpfile = io.tmpfile

    -- test that return error if io.tmpfile function returns error
    _G.io.tmpfile = function()
        errno_set(errno.EMFILE.code)
        return nil, 'failed'
    end
    package.loaded['io.fopen'] = nil
    fopen = require('io.fopen')
    local f, err = fopen(1)
    _G.io.tmpfile = tmpfile
    assert.is_nil(f)
    assert.equal(err.type, errno.EMFILE)
end

function testcase.throw_error_without_io_tmpfile()
    local tmpfile = io.tmpfile

    -- test that throws an error if io.tmpfile function is not defined
    _G.io.tmpfile = nil
    package.loaded['io.fopen'] = nil
    local err = assert.throws(function()
        fopen = require('io.fopen')
    end)
    _G.io.tmpfile = tmpfile
    assert.match(err, '"io.tmpfile" function not found')
end

local success = 0
local failure = 0
print(string.format('run %d testcases', #testfuncs))
for _, v in ipairs(testfuncs) do
    local ok, err = pcall(v.func)
    if ok then
        success = success + 1
        print(string.format('- %s ... ok', v.name))
    else
        failure = failure + 1
        print(string.format('- %s ... failed', v.name))
        print('', err)
    end
end
print('')
print(string.format('%d success, %d failure', success, failure))
os.exit(failure)
