local io = require("io")

local LoggerUitls = {}

io.stdout:setvbuf('no')

function LoggerUitls.println(str)
    io.stdout:write(str..'\n')
end

return LoggerUitls
