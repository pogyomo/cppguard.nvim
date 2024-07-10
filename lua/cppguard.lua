local M = {}

---Find CMakeLists.txt from parents.
---@return string[]
local function find_cmakelists()
    local ps = vim.fs.find("CMakeLists.txt", { upward = true })
    if #ps == 0 then
        error("failed to find CMakeLists.txt")
    end
    return ps
end

---Try to extract project name from given CMakeLists.txt
---@param path string
---@return boolean, string
local function get_project_name_from_cmakelists(path)
    local f = io.open(path, "r")
    if not f then
        error(string.format("failed to open %s", path))
    end
    for line in f:lines() do
        local success, _, name = string.find(line, "project%(%s*(%g+)%s*.*%)$")
        if success then
            return true, name
        end
    end
    return false, ""
end

---Try to get project name.
local function get_project_name()
    local ps = find_cmakelists()
    for _, path in ipairs(ps) do
        local success, name = get_project_name_from_cmakelists(path)
        if success then
            return name
        end
    end
    error("failed to get project name")
end

---Normalize given string so that it can be used in include guard.
---@param s string
---@return string
local function normalize(s)
    local normalized, _ = string.gsub(string.upper(s), "%.", "_")
    return normalized
end

---@class GenerateGuardOpts
---@field naming_method? "google"

---Generates a string which can be used at include guard.
---@param opts? GenerateGuardOpts Options for this generation.
---@return string
function M.guard_string(opts)
    opts = opts or {}
    opts.naming_method = opts.naming_method or "google"

    vim.validate {
        naming_method = {
            opts.naming_method,
            function()
                return vim.tbl_contains({
                    "google",
                }, opts.naming_method)
            end,
            "google",
        },
    }

    if opts.naming_method == "google" then
        local current_path = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
        local elements = vim.split(current_path, "/")

        local should_skip = true
        local filtered = {}
        for _, element in ipairs(elements) do
            if element == "include" or element == "src" then
                should_skip = false
            elseif not should_skip then
                filtered[#filtered + 1] = element
            end
        end

        local result = normalize(get_project_name())
        for _, element in ipairs(filtered) do
            result = string.format("%s_%s", result, normalize(element))
        end
        return result .. "_"
    else
        error("unreachable")
    end
end

---Create a snippet object that can be used for luasnip.
---@param trig string What summon this snippet
---@param opts? GenerateGuardOpts Used to generate guard.
---@return any
function M.snippet_luasnip(trig, opts)
    local ls = require("luasnip")
    local s = ls.snippet
    local f = ls.function_node
    local t = ls.text_node
    local i = ls.insert_node
    return s(trig, {
        f(function(_, _, _)
            return "#ifndef " .. M.guard_string(opts)
        end),
        t { "", "" },
        f(function(_, _, _)
            return "#define " .. M.guard_string(opts)
        end),
        t { "", "", "" },
        i(0),
        t { "", "", "" },
        f(function(_, _, _)
            return "#endif // " .. M.guard_string(opts)
        end),
    })
end

return M
