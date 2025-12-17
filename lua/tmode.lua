local api, fn = vim.api, vim.fn
---START INJECT tmode.lua

local M = {}

local name = 'u.tmode'
local ns = api.nvim_create_augroup(name, { clear = true })

M.enable = function()
  api.nvim_create_autocmd('TermEnter', { -- https://github.com/neovim/neovim/issues/26881
    group = ns,
    command = [[let b:term_insert = 1]],
  })
  api.nvim_create_autocmd('TermOpen', {
    group = ns,
    callback = function(ev)
      vim.defer_fn(function()
        if not api.nvim_buf_is_valid(ev.buf) then return end
        local ft = vim.bo[ev.buf].ft
        if ft == 'fzf' or ft == 'PlenaryTestPopup' then return end
        vim.b[ev.buf].term_insert = 1
        if api.nvim_get_current_buf() ~= ev.buf or ft ~= '' then return end
        vim.cmd [[startinsert]]
      end, 10)
      vim.keymap.set(
        { 'n', 't' },
        '<c-\\><c-n>',
        '<cmd>let b:term_insert=0<cr><c-\\><c-n>',
        { buffer = ev.buf }
      )
    end,
  })
  api.nvim_create_autocmd('BufEnter', {
    group = ns,
    pattern = 'term://*',
    callback = function(ev)
      local b = vim.b[ev.buf]
      vim.defer_fn(function()
        if
          not api.nvim_buf_is_valid(ev.buf)
          or api.nvim_get_current_buf() ~= ev.buf
          or vim.bo.ft == 'fzf'
        then
          return
        end
        if assert(b.term_insert) == 1 then
          vim.cmd [[startinsert]]
          return
        end
        vim.cmd [[stopinsert]]
        vim.defer_fn(function()
          if not api.nvim_buf_is_valid(ev.buf) or not b.term_view then return end
          for _, w in ipairs(fn.win_findbuf(ev.buf)) do
            api.nvim_win_call(w, function() fn.winrestview(b.term_view) end)
          end
        end, 10)
      end, 20)
    end,
  })
  api.nvim_create_autocmd('BufLeave', {
    group = ns,
    pattern = 'term://*',
    command = [[let b:term_view = winsaveview()]],
  })
end

M.disable = function() api.nvim_create_augroup(name, { clear = true }) end

return M
