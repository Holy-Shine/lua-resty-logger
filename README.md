# lua-resty-logger
100% non-blocking logging module for ngx_lua(openresty)

## QuickStart
1. define logger shared dict.
2. define logger object in `init_worker_by_lua` phase
3. use `logger` in other phase like `content_by_lua`, `access_by_Lua`
### 1. Define logger shared dict.
```nginx
# nginx.conf  http
lua_shared_dict log 1m;
```
### 2. Define a logger
```lua
-- init_worker_by_lua
logger = require('resty.logger').new(log_level="INFO")
```

### 3. Use logger
```lua
--- access_by_lua
logger:debug("hello world")
logger:info("hello world")
logger:warn("hello world")
logger:error("hello world")
logger:fetal("hello world")
```

