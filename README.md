# lua-io-tofile

[![test](https://github.com/mah0x211/lua-io-tofile/actions/workflows/test.yml/badge.svg)](https://github.com/mah0x211/lua-io-tofile/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/mah0x211/lua-io-tofile/branch/master/graph/badge.svg)](https://codecov.io/gh/mah0x211/lua-io-tofile)

create the lua file handle from a pathname or descriptor of the file.


## Installation

```
luarocks install io-tofile
```

---

## Error Handling

the following functions return the `error` object created by https://github.com/mah0x211/lua-errno module.


## f, err = tofile( file [, mode] )

open the lua file handle from a pathname or descriptor of the file.

**Parameters**

- `file:string|integer`: a pathname or descriptor of the file.
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


## Usage

```lua
local tofile = require('io.tofile')
local fileno = require('io.fileno')

-- open a file
local f = assert(tofile('./test.txt'))

-- new file handle from the file descriptor
-- file descriptor is duplicated with the `dup` syscall
local fd = fileno(f)
local newf = assert(tofile(fileno(f)))
print(fileno(newf)) 
```
