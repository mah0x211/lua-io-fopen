/**
 *  Copyright (C) 2022 Masatoshi Fukunaga
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to
 *  deal in the Software without restriction, including without limitation the
 *  rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *  DEALINGS IN THE SOFTWARE.
 *
 */
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
// lua
#include <lua_errno.h>

static inline FILE *fd2fp(int fd, const char *mode)
{
    FILE *fp = NULL;

    // duplicate a fd
    if ((fd = dup(fd)) == -1) {
        return NULL;
    } else if ((fp = fdopen(fd, mode))) {
        return fp;
    }
    close(fd);

    return NULL;
}

static inline int swap_fp(lua_State *L, FILE *fp)
{
    if (!fp) {
        lua_pushnil(L);
        lua_errno_new(L, errno, "fopen");
        return 2;
    }

#if LUA_VERSION_NUM >= 502
    luaL_Stream *stream = luaL_checkudata(L, -1, LUA_FILEHANDLE);
    FILE *tmpfp         = stream->f;

    stream->f = fp;
    fclose(tmpfp);

#else
    FILE **tmpfp = (FILE **)luaL_checkudata(L, -1, LUA_FILEHANDLE);
    fclose(*tmpfp);
    *tmpfp = fp;
#endif

    return 1;
}

static int REF_IO_TMPFILE = LUA_NOREF;

#define MKSTEMP_LUA(L)                                                         \
 do {                                                                          \
  lua_settop((L), 0);                                                          \
  lauxh_pushref((L), REF_IO_TMPFILE);                                          \
  lua_call((L), 0, LUA_MULTRET);                                               \
  if (lua_gettop((L)) != 1) {                                                  \
   lua_pushnil((L));                                                           \
   lua_errno_new((L), errno, "fopen");                                         \
   return 2;                                                                   \
  }                                                                            \
 } while (0)

static inline int isfile(int fd, int notfile_errno)
{
    struct stat buf = {0};
    switch (fd) {
    case STDIN_FILENO:
    case STDERR_FILENO:
    case STDOUT_FILENO:
        return 1;

    default:
        if (fstat(fd, &buf) == -1) {
            // got error
            return 0;
        } else if ((buf.st_mode & S_IFMT) != S_IFREG) {
            errno = notfile_errno;
            return 0;
        }
        return 1;
    }
}

static int fdopen_lua(lua_State *L)
{
    int fd           = lauxh_checkinteger(L, 1);
    const char *mode = lauxh_optstring(L, 2, "r");

    if (!isfile(fd, EINVAL)) {
        lua_pushnil(L);
        lua_errno_new(L, errno, "fopen");
        return 2;
    }
    MKSTEMP_LUA(L);
    return swap_fp(L, fd2fp(fd, mode));
}

static int fopen_lua(lua_State *L)
{
    if (lua_type(L, 1) == LUA_TSTRING) {
        const char *pathname = lauxh_checkstring(L, 1);
        const char *mode     = lauxh_optstring(L, 2, "r");
        FILE *fp             = NULL;

        MKSTEMP_LUA(L);
        fp = fopen(pathname, mode);
        if (fp) {
            if (!isfile(fileno(fp), ENOENT)) {
                fclose(fp);
                lua_pushnil(L);
                lua_errno_new(L, errno, "fopen");
                return 2;
            }
        }
        return swap_fp(L, fp);
    }
    return fdopen_lua(L);
}

LUALIB_API int luaopen_io_fopen(lua_State *L)
{
    lua_errno_loadlib(L);

    REF_IO_TMPFILE = LUA_NOREF;
    lauxh_getglobal(L, "io");
    if (lua_istable(L, -1)) {
        lua_pushliteral(L, "tmpfile");
        lua_rawget(L, -2);
        if (lua_isfunction(L, -1)) {
            REF_IO_TMPFILE = lauxh_ref(L);
        }
    }
    if (REF_IO_TMPFILE == LUA_NOREF) {
        return luaL_error(L, "\"io.tmpfile\" function not found");
    }

    lua_pushcfunction(L, fopen_lua);
    return 1;
}
