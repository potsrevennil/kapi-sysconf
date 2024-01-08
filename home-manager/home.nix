{ config, pkgs, kapi-vim, ... }:

{
  home = {
    stateVersion = "24.05";
    packages = with pkgs; [
      kapi-vim.packages.${system}.default
      tmux
      curl
      tokei

      nixpkgs-fmt
      nixd

      lua-language-server

      shfmt
      shellcheck

      taplo
      yaml-language-server

      codespell

      clang-tools

      rustup

      docker
      docker-buildx

      cmake
      pkg-config
      llvmPackages.clang

      go
      gopls
      gotools
      golangci-lint
      govulncheck
    ];
  };

  programs = {
    home-manager.enable = true;

    bash = {
      enable = true;
      profileExtra = "exec zsh -l";
    };

    zsh = {
      enable = true;
      autocd = true;
      loginExtra = "export SHELL=$(which zsh)";
      logoutExtra = "export SHELL=";
      syntaxHighlighting.enable = true;
      enableAutosuggestions = true;
      oh-my-zsh = {
        enable = true;
        plugins = [ "sudo" "git" "colored-man-pages" "tmux" ];
        theme = "random";
      };
    };

    git.enable = true;

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
