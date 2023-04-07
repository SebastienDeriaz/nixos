{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  nixos-wsl = import ./nixos-wsl;

  # As of 07.04.2023, Only home-manager release 22.05 works inside NixOS WSL
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz";
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"

    nixos-wsl.nixosModules.wsl

    (fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master")

    (import "${home-manager}/nixos")
  ];

  services.vscode-server.enable = true;

  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = "nixos";
    startMenuLaunchers = true;

    # Enable native Docker support
    # docker-native.enable = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker-desktop.enable = true;

  };

  # Enable nix flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "22.05";

  environment.systemPackages = with pkgs; [
    wget
    git
  ];

  # Home-manager
  home-manager.users.nixos = {
    home.stateVersion = "22.05";

    fonts.fontconfig = {
      # https://discourse.nixos.org/t/conflicting-defintions-for-build-isoimage/14619
      enable = lib.mkForce true;
    };

    home.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "Cousine"
        "FiraCode"
        "RobotoMono"
        "SourceCodePro"
      ];
    })
    bat
    entr
    exa
    expect
    fd
    fx
    fzf
    inter
    inter-ui
    material-design-icons
    moreutils
    neovim-qt
    nix-index
    nixpkgs-fmt
    noto-fonts-emoji
    ripgrep
    rnix-lsp
    tmate
    tmux
    nix-output-monitor
    # Python 3.10
    (python310.withPackages
      (pkgs: with pkgs; [
        pytest
        numpy
        scipy
        ipython
        ipykernel
        setuptools
        scipy
        pip
        matplotlib
      ])
    )
    # SVG to PDF
    #svg2pdf
  ];

  xdg.configFile."fontconfig/conf.d/20-emoji-fallback.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <alias binding="weak">
        <family>monospace</family>
        <prefer>
          <family>Noto Color Emoji</family>
        </prefer>
      </alias>
      <alias binding="weak">
        <family>sans-serif</family>
        <prefer>
          <family>Noto Color Emoji</family>
        </prefer>
      </alias>
      <alias binding="weak">
        <family>serif</family>
        <prefer>
          <family>Noto Color Emoji</family>
        </prefer>
      </alias>
    </fontconfig>
  '';

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))
      cmp-nvim-lsp
      cmp_luasnip
      fzf-lsp-nvim
      gitsigns-nvim
      lsp_extensions-nvim
      lsp_signature-nvim
      lualine-nvim
      nvim-base16
      nvim-cmp
      nvim-lspconfig
      nvim-tree-lua
      nvim-web-devicons
      vim-vsnip
    ];
    extraConfig = ''
      set ts=2 sts=2 sw=2 ai si expandtab number list mouse=a
      colorscheme base16-default-dark
      " Allow saving of files as sudo
      cmap w!! w !sudo tee > /dev/null %
      lua << EOF
      ${builtins.readFile ./nvim-init.lua}
      EOF
    '';
  };

  programs.zsh = {
    enable = true;
    initExtra = ''
      # Nix
      if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi
      # End Nix
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      source ${pkgs.nix-zsh-completions}/share/zsh/plugins/nix/nix-zsh-completions.plugin.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/lib/zsh-ls-colors/ls-colors.zsh
      fpath+=($HOME/.nix-profile/share/zsh/site-functions)
          # Reload the zsh-completions
          autoload -U compinit && compinit
          # Pretty colours in less command
          export LESS_TERMCAP_mb=$'\E[01;31m'
          export LESS_TERMCAP_md=$'\E[01;38;5;74m'
          export LESS_TERMCAP_me=$'\E[0m'
          export LESS_TERMCAP_se=$'\E[0m'
          export LESS_TERMCAP_so=$'\E[38;5;246m'
          export LESS_TERMCAP_ue=$'\E[0m'
          export LESS_TERMCAP_us=$'\E[04;38;5;146m'
          # Functional Home-/End-/Delete-/Insert-keys
          bindkey '\e[1~'   beginning-of-line  # Linux console
          bindkey '\e[H'    beginning-of-line  # xterm
          bindkey '\e[2~'   overwrite-mode     # Linux console, xterm, gnome-terminal
          bindkey '\e[3~'   delete-char        # Linux console, xterm, gnome-terminal
          bindkey '\e[4~'   end-of-line        # Linux console
          bindkey '\e[F'    end-of-line        # xterm
          bindkey "^[[1;5C" forward-word
          bindkey "^[[1;5D" backward-word
          bindkey "^[[A" history-substring-search-up
          bindkey "^[[B" history-substring-search-down
          # set list-colors to enable filename colorizing
          zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
    '';
    shellAliases = {
      open = ''open() { xdg-open "$@" & disown }; open'';
      exa = "exa --tree --icons";
      ls = "ls --color=auto";
      gvim = "nvim-qt";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings.character = {
      #      success_symbol = "🐺";
      #      error_symbol = "🐺";
      #      vicmd_symbol = "🐺";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  };
}
