local utils = require "snvim.utils.core"
local settings = require "snvim.utils.settings"

utils.define_augroups(settings.get_settings("autocommands"))
