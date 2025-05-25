{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
{
  home.packages = with pkgs; [ vim ];
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      extraPackages = with pkgs; [
        xclip
        wl-clipboard

        # LSP
        luajitPackages.lua-lsp
        nixd
        rust-analyzer
        tailwindcss-language-server
        nodePackages.bash-language-server
        yaml-language-server
        pyright
        marksman
        vue-language-server
        typescript-language-server
        nodePackages.typescript-language-server
        eslint_d
        gopls
        clang-tools
        vscode-langservers-extracted

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
        asmfmt

        tree-sitter-grammars.tree-sitter-markdown
        tree-sitter-grammars.tree-sitter-markdown-inline
      ];
      plugins = with pkgs.vimPlugins; [
        plenary-nvim
        # Theme

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
        scope-nvim
        nui-nvim
        img-clip-nvim
        render-markdown-nvim
        markdown-preview-nvim
        nvim-colorizer-lua # View colors in nvim
      ];
      extraLuaConfig = ''
        ${builtins.readFile ./options.lua}
        ${builtins.readFile ./keymaps.lua}
        ${builtins.readFile ./plugins/alpha.lua}
        ${builtins.readFile ./plugins/autopairs.lua}
        ${builtins.readFile ./plugins/auto-session.lua}
        ${builtins.readFile ./plugins/comment.lua}
        ${builtins.readFile ./plugins/bufferline.lua}
        ${builtins.readFile ./plugins/colorscheme.lua}
        ${builtins.readFile ./plugins/dressing.lua}
        ${builtins.readFile ./plugins/formatting.lua}
        ${builtins.readFile ./plugins/gitsigns.lua}
        ${builtins.readFile ./plugins/indent-blankline.lua}
        ${builtins.readFile ./plugins/lazygit.lua}
        ${builtins.readFile ./plugins/linting.lua}
        ${builtins.readFile ./plugins/lsp/lspconfig.lua}
        ${builtins.readFile ./plugins/lualine.lua}
        ${builtins.readFile ./plugins/nvim-cmp.lua}
        ${builtins.readFile ./plugins/nvim-tree.lua}
        ${builtins.readFile ./plugins/nvim-treesitter-text-objects.lua}
        ${builtins.readFile ./plugins/substitute.lua}
        ${builtins.readFile ./plugins/surround.lua}
        ${builtins.readFile ./plugins/telescope.lua}
        ${builtins.readFile ./plugins/todo-comments.lua}
        ${builtins.readFile ./plugins/treesitter.lua}
        ${builtins.readFile ./plugins/trouble.lua}
        ${builtins.readFile ./plugins/vim-maximizer.lua}
        ${builtins.readFile ./plugins/which-key.lua}
        ${builtins.readFile ./plugins/harpoon.lua}
        ${builtins.readFile ./plugins/scope.lua}
        ${builtins.readFile ./plugins/colorizer.lua}

        lspconfig.ts_ls.setup({
        	capabilities = capabilities,
        	init_options = {
        		plugins = { -- I think this was my breakthrough that made it work
        			{
        				name = "@vue/typescript-plugin",
        				location = "${lib.getBin pkgs.vue-language-server}/lib/node_modules/@vue/language-server",
        				languages = { "javascript", "typescript", "vue" },
        			},
        		},
        	},
        	filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        })


        require("lspconfig").nixd.setup({
        	cmd = { "nixd" },
        	capabilities = capabilities,
        	settings = {
        		nixd = {
        			nixpkgs = {
        				expr = "import <nixpkgs> { }",
        			},
        			formatting = {
        				command = { "nixfmt" },
        			},
        			options = {
        				nixos = {
        					expr = '(builtins.getFlake "${config.hostSpec.home}/nix-config").nixosConfigurations.${config.hostSpec.hostName}.options',
        				},
        				home_manager = {
        					expr = '(builtins.getFlake "${config.hostSpec.home}/nix-config").nixosConfigurations.${config.hostSpec.hostName}.options.home-manager.users.value.${config.hostSpec.username}',
        				},
        			},
        		},
        	},
        })

      '';
    };
  };
  stylix.targets.neovim.plugin = "base16-nvim"; # This is for lualine in nvim

  /*
    Note:
    nixd completion doesn't work with config.s<tab>

    the following works fine:
    config = lib.mkIf true{
      h<tab>
    }

    ref: https://github.com/nix-community/nixd/issues/566
  */
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ]; # This is for nixd
}
