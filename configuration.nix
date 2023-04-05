{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  nixos-wsl = import ./nixos-wsl;
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"

    nixos-wsl.nixosModules.wsl

    <home-manager/nixos>

    (fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master")

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

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    nodejs
    git
  ];

  home-manager.users.nixos = { pkgs, ... }: {
    home.stateVersion = "22.11";
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
    # VS Code
    vscode
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
    svg2pdf
    ];
  };

}
