local M = {}

-- delay notifications until vim.notify was replaced, or after 500ms
function M.lazy_notify()
  -- Override the original vim.notify function with a temporary one,
  -- which will store any received call arguments.
  local notifs = {}
  local function temp(...)
    table.insert(notifs, vim.F.pack_len(...))
  end

  local orig = vim.notify
  vim.notify = temp

  local timer = vim.loop.new_timer()
  local check = vim.loop.new_check()

  -- Function to send out all of the captured notifications
  -- (requires vim.notify to already be overwritten/original)
  local function resend_notifications()
    vim.schedule(function()
      for _, notif in ipairs(notifs) do
        vim.notify(vim.F.unpack_len(notif))
      end
    end)
  end

  -- Start checking for a change of vim.notify.
  -- If it's no longer our temp function, it means a plugin has overwritten it,
  -- and so we can stop checking and stop the timer.
  --
  -- (This check will run on every event loop iteration)
  ---@diagnostic disable-next-line: need-check-nil
  check:start(function()
    if vim.notify ~= temp then
      ---@diagnostic disable-next-line: need-check-nil
      timer:stop()
      ---- trigger the timer callback function, sending all of the captured notifications
      ---@diagnostic disable-next-line: need-check-nil
      timer:close(resend_notifications)
      ---@diagnostic disable-next-line: need-check-nil
      check:stop()
    end
  end)

  -- Start a 500ms timer, triggering a callback function once it ends (without being aborted)
  -- This callback then resets vim.notify to the original function, and sends out all of the
  -- captured notifications.
  ---@diagnostic disable-next-line: need-check-nil
  timer:start(500, 0, function()
    ---@diagnostic disable-next-line: need-check-nil
    check:stop()

    vim.notify = orig
    resend_notifications()
  end)
end

return M
