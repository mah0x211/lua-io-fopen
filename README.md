# lua-io-fopen

[![test](https://github.com/mah0x211/lua-io-fopen/actions/workflows/test.yml/badge.svg)](https://github.com/mah0x211/lua-io-fopen/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/mah0x211/lua-io-fopen/branch/master/graph/badge.svg)](https://codecov.io/gh/mah0x211/lua-io-fopen)

create the lua file handle from a pathname or descriptor of the file.


## Installation

```
luarocks install io-fopen
```

---

## Error Handling

the following functions return the `error` object created by https://github.com/mah0x211/lua-errno module.


## f, err = fopen( file [, mode] )

open the lua file handle from a pathname or descriptor of the file.

**NOTE**

this function uses the `dup` system call internally to duplicate a file descriptor and create a new file handle from it.

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
local fopen = require('io.fopen')
local fileno = require('io.fileno')

-- open a file
local f = assert(fopen('./test.txt'))

-- new file handle from the file descriptor
-- file descriptor is duplicated with the `dup` syscall
local fd = fileno(f)
local newf = assert(fopen(fileno(f)))
print(fileno(newf)) 
```
