local M = {}

local function link_target_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col(".")
  local from = 1

  while true do
    local start_col, end_col, _, target = line:find("%[(.-)%]%((.-)%)", from)
    if not start_col then
      break
    end
    if col >= start_col and col <= end_col then
      return target:match("^%s*<([^>]+)>") or target:match("^%s*(%S+)")
    end
    from = end_col + 1
  end

  from = 1
  while true do
    local start_col, end_col, target = line:find("%[%[(.-)%]%]", from)
    if not start_col then
      break
    end
    if col >= start_col and col <= end_col then
      target = target:match("^(.-)|") or target
      return vim.trim(target)
    end
    from = end_col + 1
  end
end

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function(ev)
      vim.opt_local.conceallevel = 2
      vim.keymap.set("n", "<leader>mp", "<Cmd>MdRender<CR>", {
        buffer = ev.buf,
        desc = "Markdown: toggle rendered preview",
      })
      vim.keymap.set("n", "<leader>ms", "<Cmd>MdRender split<CR>", {
        buffer = ev.buf,
        desc = "Markdown: source and rendered split",
      })
    end,
  })

  vim.api.nvim_create_user_command("ObsidianCopyLinkUnderCursor", function()
    local target = link_target_at_cursor()
    if not target or target == "" then
      vim.notify("No Markdown or Obsidian link under cursor", vim.log.levels.WARN)
      return
    end

    vim.fn.setreg("+", target)
    vim.notify("Copied link target to clipboard")
  end, {
    desc = "Copy the Markdown or Obsidian link target under the cursor",
    force = true,
  })

  vim.cmd([[
    silent! aunmenu PopUp.Copy\ Link
    anoremenu <silent> PopUp.Copy\ Link <Cmd>ObsidianCopyLinkUnderCursor<CR>
  ]])

  -- Vault paths are machine-specific and stay in the untracked local.lua.
  local has_local, localcfg = pcall(dofile, vim.fn.stdpath("config") .. "/local.lua")
  local workspaces = {}
  if has_local and type(localcfg) == "table" then
    if type(localcfg.vaults) == "table" then
      for _, workspace in ipairs(localcfg.vaults) do
        if type(workspace) == "table" and type(workspace.path) == "string" then
          local path = vim.fn.expand(workspace.path)
          if vim.fn.isdirectory(path) == 1 then
            table.insert(workspaces, { name = workspace.name or "notes", path = path })
          end
        end
      end
    elseif type(localcfg.vault) == "string" then
      local path = vim.fn.expand(localcfg.vault)
      if vim.fn.isdirectory(path) == 1 then
        workspaces = { { name = "notes", path = path } }
      end
    end
  end
  if #workspaces > 0 then
    require("obsidian").setup({
      legacy_commands = false,
      workspaces = workspaces,
      picker = { name = "telescope.nvim" },
    })
    vim.keymap.set("n", "<leader>on", "<CMD>Obsidian new<CR>", { desc = "Obsidian: new note" })
    vim.keymap.set("n", "<leader>os", "<CMD>Obsidian search<CR>", { desc = "Obsidian: search notes" })
    vim.keymap.set("n", "<leader>oq", "<CMD>Obsidian quick_switch<CR>", { desc = "Obsidian: quick switch" })
    vim.keymap.set("n", "<leader>ob", "<CMD>Obsidian backlinks<CR>", { desc = "Obsidian: backlinks" })
    vim.keymap.set("n", "<leader>ot", "<CMD>Obsidian today<CR>", { desc = "Obsidian: today's note" })
  end
end

return M
