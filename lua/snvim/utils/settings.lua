local M = {}


-- Get settings for given name
--@param name string @Configuration require name (will be prefixed by snvim.settings.)
--@returns table
function M.get_settings(name)
    local ok, conf = pcall(require, "snvim.settings." .. name)
    if not ok then
        error(string.format("Unable to get %s settings: %s", name, conf))
    end

    -- If the configuration file has some init, run it, otherwise continue
    if conf.init ~= nil then
        local typ = type(conf.init)
        if typ ~= "function" then
            error(string.format("'init' attribute of '%s' settings must be a function or nil, not %s%.", name, typ))
        end

        -- We now know init is present and it's a function, execute it
        conf.init()
    end

    -- We expect all config files to have 'config' attribute
    if conf.config == nil then
        error(string.format("'config' attribute of '%s' settings must be set!", name))
    end
    return conf.config
end


return M
