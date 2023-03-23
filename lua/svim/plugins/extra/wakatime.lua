return {
  -- Code time & habit tracking
  "wakatime/vim-wakatime",
  event = { "BufReadPost", "BufNewFile" },
  cmd = {
    "WakaTimeApiKey",
    "WakaTimeDebugEnable",
    "WakaTimeDebugDisable",
    "WakaTimeScreenRedrawEnable",
    "WakaTimeScreenRedrawEnableAuto",
    "WakaTimeScreenRedrawDisable",
    "WakaTimeToday",
    "WakaTimeCliLocation",
    "WakaTimeCliVersion",
    "WakaTimeFileExpert",
  },
}
