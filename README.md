# lua-io-tofile

[![test](https://github.com/mah0x211/lua-io-tofile/actions/workflows/test.yml/badge.svg)](https://github.com/mah0x211/lua-io-tofile/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/mah0x211/lua-io-tofile/branch/master/graph/badge.svg)](https://codecov.io/gh/mah0x211/lua-io-tofile)

create the lua file handle from the file descriptor.


## Installation

```
luarocks install io-tofile
```

---

## Error Handling

the following functions return the `error` object created by https://github.com/mah0x211/lua-errno module.


## f, err = tofile( fd [, mode] )

create the lua file handle from the file descriptor.

**Parameters**

- `fd:integer`: the file descriptor.
- `mode:string`: the mode string can be any of the following:
  - `'r'`: read mode (the default);
  - `'w'`: write mode;
  - `'a'`: append mode;
  - `'r+'`: update mode, all previous data is preserved;
  - `'w+'`: update mode, all previous data is erased;
  - `'a+'`: append update mode, previous data is preserved, writing is only allowed at the end of file.

**Returns**

- `f:file`: lua file handle.
- `err:error`: error object.


**e.g.**

```lua
local tofile = require('io.tofile')
local fileno = require('io.fileno')
local f = assert(io.open('./test.txt', 'w'))
local fd = fileno(f)

-- returns new file handle from the file descriptor
local newf = assert(tofile(fd))
-- file descriptor is duplicated with the `dup` function
print(fileno(newf)) 
```

