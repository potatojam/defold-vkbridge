-- @module sitelock

local M = {}

M.domains = {"vk", "localhost"}

local function ends_with(s, substr)
    return s:sub(-#substr) == substr
end

---Adds a domain to the list
---@param domain string
function M.add_domain(domain)
    table.insert(M.domains, domain)
end

---Compares the current hostname to the domains from the list.
---@return boolean
function M.verify_domain()
    if not html5 then
        return true
    end
    local current_domain = html5.run("window.location.hostname")
    for key, value in ipairs(M.domains) do
        if value == current_domain or ends_with(current_domain, "." .. value) then
            return true
        end
    end
    return false
end

---Returns the current domain name (hostname).
---@return string
function M.get_current_domain()
    if html5 then
        return html5.run("window.location.hostname")
    else
        return ""
    end
end

---Checks the build type
---@return boolean
function M.is_release_build()
    return not sys.get_engine_info().is_debug
end

return M
