local M = {}

M.config = {
    git = {
        clone_timeout = 300,
        subcommands = {
        -- this is more efficient than what Packer is using by default
        fetch = "fetch --no-tags --no-recurse-submodules --update-shallow --progress",
        }
    },
    max_jobs = 50,
    display = {
        open_fn = function()
            return require("packer.util").float { border = "rounded" }
        end,
    }
}

-- Add "log" setting with current loglevel
function M.init()
    M.config.log = { level = Snvim.log_level }
    M.config.package_root = Snvim.package_root
    M.config.compile_path = Snvim.compile_path
end

return M
