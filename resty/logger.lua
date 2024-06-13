local io    = require("io")
local utils = require("resty.logger_utils")


local println = utils.println


local ngx        = ngx
local log_shared = ngx.shared.logger
-- global variables
local LOGGER_LEVELS              = {["DEBUG"]=1, ["INFO"]=2, ["WARN"]=3, ["ERROR"]=4, ["FETAL"]=5}
local LOGGER_OUT_STDOUT          = "STDOUT"  -- default logger output: stdout
local LOGGER_DEFAULT_ROTATE_DAYS = 3         -- default logger rotate days
local LOGGER_BUFFER_KEY          = 'log'

io.stdout:setvbuf('no')

local _M = {}
_M._VERSION = '1.0'

local mt = { __index = _M }






function _M.new(log_level, log_path, log_rotate_days)
    local self = setmetatable({}, mt)
    self.log_level       = LOGGER_LEVELS[log_level]
    self.log_path        = log_path or LOGGER_OUT_STDOUT
    self.log_rotate_days = log_rotate_days or LOGGER_DEFAULT_ROTATE_DAYS

    -- start a timer to output logs.
    -- only one worker output log
    if ngx.worker.id() == 0 then
        ngx.timer.at(0, self.output_logs, 5, self)
    end
    return self
end


function _M:output_logs()
    local logs = log_shared:get(LOGGER_BUFFER_KEY)
    if logs and logs ~= '' then
        if self.log_path == LOGGER_OUT_STDOUT then
            println(logs)
        else
            println(logs)
        end
    end
    log_shared:set(LOGGER_BUFFER_KEY, '')
end




function _M:output(log_level, log_str)
    if self.log_level <= log_level then
        local ngx_phase = ngx.get_phase()

        if ngx_phase == 'init_worker' or ngx_phase == 'timer' then
            println(log_str)
            return
        end

        -- update log buffer
        local logs = log_shared:get(LOGGER_BUFFER_KEY) or ''
        logs = logs..log_str
        log_shared:set(LOGGER_BUFFER_KEY, logs)

    end
end

function _M:debug(s)
    self:output(1, s)
end

function _M:info(s)
    self:output(2, s)
end

function _M:warn(s)
    self:output(3, s)
end

function _M:error(s)
    self:output(4, s)
end

function _M:fetal(s)
    self:output(5, s)
end



return _M