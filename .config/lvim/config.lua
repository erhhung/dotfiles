-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- https://www.lunarvim.org/docs/configuration/plugins/example-configurations
lvim.plugins = {
  -- https://github.com/askfiy/visual_studio_code
  -- Visual Studio Code color theme
  {
    "askfiy/visual_studio_code",
    priority = 100,
    config = function()
      vim.cmd([[colorscheme visual_studio_code]])
    end,
  },

  -- https://github.com/nvim-neo-tree/neo-tree.nvim
  -- File explorer replacing NvimTree
  -- <leader>e
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        window = {
          width = 50,
        },
        buffers = {
          follow_current_file = {
            enabled = true,
          },
        },
        filesystem = {
          follow_current_file = {
            enabled = true,
          },
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_by_name = {
              "node_modules",
            },
            never_show = {
              ".DS_Store",
              "thumbs.db",
            },
          },
        },
      })
    end,
  },

  -- https://github.com/wfxr/minimap.vim
  -- Show minimap on right with scrolling
  -- :Minimap
  {
    "wfxr/minimap.vim",
    build = "cargo install --locked code-minimap",
    -- cmd = {"Minimap", "MinimapClose", "MinimapToggle", "MinimapRefresh", "MinimapUpdateHighlight"},
    config = function ()
      vim.cmd("let g:minimap_width = 13")
      vim.cmd("let g:minimap_auto_start = 1")
      vim.cmd("let g:minimap_auto_start_win_enter = 1")
    end,
  },

  -- https://github.com/nvim-pack/nvim-spectre
  -- An interactive search panel with regex
  -- :Spectre
  {
    "windwp/nvim-spectre",
    event = "BufRead",
    config = function()
      require("spectre").setup()
    end,
  },

  -- https://github.com/ibhagwan/fzf-lua
  -- Improved fzf.vim written in lua
  { "ibhagwan/fzf-lua" },

  -- https://github.com/github/copilot.vim
  { "github/copilot.vim" },

  -- https://github.com/casey/just
  -- Syntax highlighting for justfile
  { "NoahTheDuke/vim-just" },
}

-- https://www.lunarvim.org/docs/configuration/appearance/colorschemes
lvim.colorscheme = "visual_studio_code"
-- lvim.transparent_window = true
lvim.autocommands = {
  {
    { "ColorScheme" },
    {
      pattern = "*",
      callback = function()
        -- make highlight colors of current theme brighter
        vim.api.nvim_set_hl(0,    "Search", { fg = "Black", bg = "#bfbf60" })
        vim.api.nvim_set_hl(0, "IncSearch", { fg = "Black", bg = "#d1d111" })
        vim.api.nvim_set_hl(0, "CurSearch", { link = "IncSearch" })
      end,
    },
  },
}

-- https://www.lunarvim.org/docs/configuration/appearance/statusline
lvim.builtin.lualine.style = "default"
-- https://github.com/nvim-lualine/lualine.nvim/blob/master/THEMES.md
lvim.builtin.lualine.options.theme = "codedark"

-- https://stackoverflow.com/questions/657447/vim-clear-last-search-highlighting
-- https://www.lunarvim.org/docs/configuration/keybindings
-- (echon '' clears the status line)
lvim.keys.normal_mode["<ESC><ESC>"] = ":noh<CR>:call clearmatches()<CR>:echon ''<CR>"

-- Ctrl-z/Ctrl-Shift-z: undo and redo
lvim.keys.insert_mode["<C-z>"]   = "<C-o>u"
lvim.keys.insert_mode["<C-S-z>"] = "<C-o><C-r>"
-- Ctrl-s: save staying in insert mode
lvim.keys.insert_mode["<C-s>"]   = "<C-o>:w<CR>"

lvim.builtin.which_key.mappings["e"] = {
  "<cmd>Neotree toggle<CR>", "Neotree"
}

lvim.builtin.nvimtree.active = false -- using neo-tree instead

-- Fix not loading ~/.bash_profile by default
vim.opt.shell = "/usr/local/bin/bash --login"

-- Always enter insert mode when switching to terminal pane
-- https://vi.stackexchange.com/questions/3670/how-to-enter-insert-mode-when-entering-neovim-terminal-pane
-- https://vi.stackexchange.com/questions/4919/exit-from-terminal-mode-in-neovim-vim-8
vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
  pattern = { "*" },
  callback = function()
    if vim.opt.buftype:get() == "terminal" then
      vim.cmd(":startinsert")            -- go insert mode
      vim.cmd(":setlocal nonumber")      -- no line numbers
      vim.cmd(":setlocal signcolumn=no") -- no left margin
      -- remap arcane C-\ C-n to return to normal mode
      vim.cmd(":tnoremap <leader><ESC> <C-\\><C-n>")
    end
  end,
})

vim.opt.tabstop = 2    -- spaces per tab
vim.opt.shiftwidth = 2 -- spaces per indent

-- Use treesitter folding
-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

