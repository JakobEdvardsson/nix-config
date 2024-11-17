{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  finecmdline = pkgs.vimUtils.buildVimPlugin {
    name = "fine-cmdline";
    src = inputs.fine-cmdline;
  };
in
{
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      extraPackages = with pkgs; [
        xclip
        wl-clipboard

        # LSP
        luajitPackages.lua-lsp
        nil
        rust-analyzer
        tailwindcss-language-server
        nodePackages.bash-language-server
        yaml-language-server
        pyright
        marksman
        vue-language-server
        typescript-language-server
        nodePackages.typescript-language-server
        sourcekit-lsp
        eslint_d
        gopls

        #nodePackages.vls
        lua-language-server
        gopls
        emmet-ls

        # Code formatting
        stylua
        vimPlugins.vim-isort
        black
        nodePackages.prettier
        nixfmt-rfc-style
        shfmt
        pylint

        tree-sitter-grammars.tree-sitter-markdown
        tree-sitter-grammars.tree-sitter-markdown-inline

      ];
      plugins = with pkgs.vimPlugins; [
        plenary-nvim
        tokyonight-nvim
        vim-tmux-navigator
        nvim-surround
        substitute-nvim
        nvim-tree-lua
        nvim-web-devicons
        alpha-nvim
        auto-session
        lualine-nvim
        bufferline-nvim
        which-key-nvim
        telescope-fzf-native-nvim
        telescope-nvim
        dressing-nvim
        nvim-cmp
        cmp-buffer
        cmp-path
        lspkind-nvim
        luasnip
        friendly-snippets
        cmp_luasnip
        nvim-lspconfig
        cmp-nvim-lsp
        trouble-nvim
        conform-nvim
        nvim-lint
        comment-nvim
        nvim-ts-context-commentstring
        todo-comments-nvim
        nvim-treesitter.withAllGrammars
        nvim-treesitter-textobjects
        nvim-autopairs
        nvim-ts-autotag
        indent-blankline-nvim
        gitsigns-nvim
        lazygit-nvim
        harpoon2
        finecmdline
        scope-nvim
        nui-nvim
        img-clip-nvim
        avante-nvim
        render-markdown-nvim

      ];
      extraConfig = ''
        set noemoji
      '';
      extraLuaConfig = ''
        ${builtins.readFile ./nvim/options.lua}
        ${builtins.readFile ./nvim/keymaps.lua}
        ${builtins.readFile ./nvim/plugins/alpha.lua}
        ${builtins.readFile ./nvim/plugins/autopairs.lua}
        ${builtins.readFile ./nvim/plugins/auto-session.lua}
        ${builtins.readFile ./nvim/plugins/comment.lua}
        ${builtins.readFile ./nvim/plugins/bufferline.lua}
        ${builtins.readFile ./nvim/plugins/colorscheme.lua}
        ${builtins.readFile ./nvim/plugins/dressing.lua}
        ${builtins.readFile ./nvim/plugins/formatting.lua}
        ${builtins.readFile ./nvim/plugins/gitsigns.lua}
        ${builtins.readFile ./nvim/plugins/indent-blankline.lua}
        ${builtins.readFile ./nvim/plugins/lazygit.lua}
        ${builtins.readFile ./nvim/plugins/linting.lua}
        ${builtins.readFile ./nvim/plugins/lsp/lspconfig.lua}
        ${builtins.readFile ./nvim/plugins/lualine.lua}
        ${builtins.readFile ./nvim/plugins/nvim-cmp.lua}
        ${builtins.readFile ./nvim/plugins/nvim-tree.lua}
        ${builtins.readFile ./nvim/plugins/nvim-treesitter-text-objects.lua}
        ${builtins.readFile ./nvim/plugins/substitute.lua}
        ${builtins.readFile ./nvim/plugins/surround.lua}
        ${builtins.readFile ./nvim/plugins/telescope.lua}
        ${builtins.readFile ./nvim/plugins/todo-comments.lua}
        ${builtins.readFile ./nvim/plugins/treesitter.lua}
        ${builtins.readFile ./nvim/plugins/trouble.lua}
        ${builtins.readFile ./nvim/plugins/vim-maximizer.lua}
        ${builtins.readFile ./nvim/plugins/which-key.lua}
        ${builtins.readFile ./nvim/plugins/harpoon.lua}
        ${builtins.readFile ./nvim/plugins/fine-cmdline.lua}
        ${builtins.readFile ./nvim/plugins/scope.lua}
        ${builtins.readFile ./nvim/plugins/avante.lua}

        lspconfig.ts_ls.setup({
          capabilities = capabilities,
          init_options = {
            plugins = { -- I think this was my breakthrough that made it work
              {
                name = "@vue/typescript-plugin",
                location = "${lib.getBin pkgs.vue-language-server}/lib/node_modules/@vue/language-server",
                languages = {"javascript", "typescript", "vue"},
              },
            },
          },
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        })
      '';
    };
  };
}
