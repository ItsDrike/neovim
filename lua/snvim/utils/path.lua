local M = {}

local os_name = vim.loop.os_uname().version
M.path_separator = os_name:match "Windows" and "\\" or "/"


-- Safely join paths together, regardless of the OS
--@param ... string @string paths to be joined together
--@returns string @Resulting path by joining the given paths by the OS-specific separator
function M.join_paths(...)
    return table.concat({ ... }, M.path_separator)
end



-- Split the path by separators into a list of it's sections
--@param path string
--@returns table<int, string>
function M.split_path(path)
    local pattern = string.format("([^%s]+)", M.path_separator)
    local parts = {}
    for part in string.gmatch(path, pattern) do
        table.insert(parts, part)
    end
    return parts
end


-- Check whether a given path exists and is a directory
--@param path string
--@returns bool
function M.is_directory(path)
    local stat = vim.loop.fs_stat(path)
    return stat and stat.type == "directory" or false
end


-- Check whether a given path exists and is a file
--@param path string
--@returns bool
function M.is_file(path)
    local stat = vim.loop.fs_stat(path)
    return stat and stat.type == "file" or false
end


return M
