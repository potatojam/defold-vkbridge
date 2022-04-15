local M = {}

-- https://stackoverflow.com/questions/1426954/split-string-in-lua
local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

---Create limit by name
---@param name string
---@param reset_time number the time after which the limit will be reset
---@return table
function M.create_limit(name, reset_time)
    local max = tonumber(sys.get_config("vk_bridge." .. name, "0")) or 0
    local limit = {count = 0, max = max, active = max ~= nil and max > 0, name = name, time = socket.gettime(), reset_time = reset_time or max}
    return limit
end

---Checks the date and parse it if the date is correct
---@param limit table limit object
---@param data table `{key = string, value = string}`
function M.parse_limit(limit, data)
    if limit.name == data.key then
        local parsed = split(data.value, ";")
        local value = parsed[1]
        local time = parsed[2]
        limit.count = tonumber(value) or 0
        limit.time = tonumber(time) or socket.gettime()
    end
end

---Return value for server save
---@param limit table limit object
---@return string
function M.get_save_value(limit)
    return tostring(limit.count) .. ";" .. tostring(limit.time)
end

---Check timer limit. Returns `true` if the limit has been exceeded
---@param limit table limit object
---@return boolean
function M.is_time_exceeded(limit)
    if not limit.active then
        return false
    end
    return socket.gettime() - limit.time < limit.reset_time
end

---Reset time limit if it need
---@param limit table
function M.reset_time(limit)
    if socket.gettime() - limit.time >= limit.reset_time then
        limit.count = 0
        limit.time = socket.gettime()
    end
end

---Check timer and check available ads. Reset time if limit exceeded. Returns `true` if the limit has been exceeded
---@param limit table limit object
---@return boolean
function M.is_count_exceeded(limit)
    if not limit.active then
        return false
    end
    M.reset_time(limit)
    if limit.count < limit.max then
        return false
    end
    return true
end

---Increase limit value
---@param limit table
function M.increase(limit)
    limit.count = limit.count + 1
end

return M
