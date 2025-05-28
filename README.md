# ai-git.nvim

**Locally-Powered Git Commit Messages, Right in Neovim.**

[![Neovim](https://img.shields.io/badge/Neovim-0.8+-blue?logo=neovim)](https://neovim.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

### ✨ Introduction

**`ai-git.nvim`** is a Neovim plugin designed to enhance your Git workflow. It provides a dedicated UI to generate concise, relevant, and Conventional Commit style messages for your **commits**, directly within your editor. Review staged changes, see their diffs, and edit the generated message before committing.

### 🚀 Key Features

- **Locally Generated Commit Messages:** Analyzes staged changes (from `git diff --staged`) to propose Conventional Commit messages (e.g., `feat:`, `fix:`).
- **Interactive Commit UI:** Provides a dedicated UI to view staged files, their diffs, and edit the generated commit message before committing.
- **Seamless Neovim Integration:** Works directly within your Neovim session.
- **Vim-Fugitive Integration:** Uses `vim-fugitive` for the commit action.
- **Contextual Merge Messages:** (Merge message generation is currently disabled as it relied on the previous AI backend).
- **Improved Consistency:** Fosters a clearer and more readable Git history, ideal for teams and long-term projects.

### 💡 How It Works (Plugin Usage)

The primary way to use `ai-git.nvim` for commit messages is via its interactive UI:

1.  **Stage your changes in Git:**
    ```bash
    git add .
    ```
2.  **Open the Commit UI:** Run the command `:GeminiCommitMsg` (or press `<leader>gc`).
    _(Note: The command name `GeminiCommitMsg` is a remnant of previous versions; it now triggers the local commit message UI)._
3.  **The plugin interface will open, showing three main panels:**
    - **Top-Right (DBB-1): Staged Files List:** Lists all files you've staged for the commit.
      - Navigate this list and press `<CR>` (Enter) on a file to view its diff in the left panel.
    - **Left (DBA): Diff View:** Shows the diff for the file selected from the Staged Files List.
    - **Bottom-Right (DBB-2): Commit Message Area:**
      - An initial commit message is automatically generated based on your staged changes.
      - You can edit this message as needed.
      - To commit, press `<leader>c` while your cursor is in this panel. This will use `vim-fugitive` to perform the commit with the message content.

### ⚙️ Installation

#### Requirements:

- **Neovim:** Version 0.8 or higher (tested with 0.8, UI features might benefit from 0.9+ but not strictly required by current implementation).
- **Git:** Essential for version control.
- **`tpope/vim-fugitive`:** Required for the commit action.
- **`lewis6991/gitsigns.nvim`:** Recommended for a better Git experience within Neovim (provides sign column, blame, etc.).
- **`sindrets/diffview.nvim`:** Recommended for an enhanced diff viewing experience (the plugin uses a basic diff view in one of its panels).

##### Installation with `lazy.nvim`:

Add the plugin to your `lazy.nvim` configuration:

```lua
-- In your lazy.nvim plugin configuration:
{
    "jrsimog/ai-git.nvim", -- Ensure this is the correct GitHub path
    dependencies = {
        "tpope/vim-fugitive",
        "lewis6991/gitsigns.nvim", -- Recommended
        "sindrets/diffview.nvim", -- Recommended for enhanced diff viewing
    },
    config = function()
        require("ai-git").setup() -- Initializes the plugin
    end,
    -- Optional: Specify a version tag if available
    -- version = "*"
}
```

Then, open Neovim and run `:Lazy sync` (or your lazy.nvim update command) to install the plugin.

##### Installation with `packer.nvim`:

Add the plugin to your Packer configuration:

```lua
-- ~/.config/nvim/lua/plugins.lua (or where you configure packer)

return require('packer').startup(function(use)
    -- ... your other plugins

    use {
        "jrsimog/ai-git.nvim",
        requires = {
            {"tpope/vim-fugitive"},
            {"lewis6991/gitsigns.nvim"}, -- Optional but recommended
            {"sindrets/diffview.nvim"}, -- Optional but recommended
        },
        config = function()
            require("ai-git").setup() -- Initialize the plugin
        end,
    }

    -- ... your other plugins
end)
```

Then, open Neovim and run `:PackerSync` (or `:PackerInstall`).

##### Installation with `vim-plug`:

Add the plugin to your `init.vim` (or `~/.vimrc`) file:

```vim
" ~/.vimrc or ~/.config/nvim/init.vim

call plug#begin()

" ... your other plugins

Plug 'tpope/vim-fugitive' " Dependency
Plug 'lewis6991/gitsigns.nvim' " Recommended
Plug 'sindrets/diffview.nvim' " Recommended
Plug 'jrsimog/ai-git.nvim'

" ... your other plugins

call plug#end()

" Configuration for ai-git.nvim (needs to be in Lua)
lua << EOF
require("ai-git").setup() -- Initialize the plugin
EOF
```

Then, open Neovim and run `:PlugInstall`.

#### Keymaps

The plugin automatically sets up the following keymap:

- `<leader>gc`: Triggers the `:GeminiCommitMsg` command, opening the AI Commit Message UI.
- `<leader>gm`: Triggers `:GeminiMergeMsg`. (Note: Merge message generation is currently non-functional as it relied on a previous AI backend and is pending rework).

The command `:GeminiMergeMsg` is also available but its core functionality is currently disabled.

### 🤝 Contributing

Contributions are welcome! If you find a bug, have a feature request, or want to improve the codebase, please feel free to open an issue or submit a pull request.

### 📄 License

This plugin is licensed under the MIT License.

### Hashtags for Search

#Neovim #Nvim #Git #CommitMessage #ConventionalCommits #GitUI #Productivity #DevTools #Lua #VimPlugin #DeveloperTools #GitWorkflow #LazyNvim #PackerNvim #VimPlug #Fugitive
