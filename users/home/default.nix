{ config, pkgs, dotfiles, ... }:

{
  home = {
    packages = builtins.attrValues {
      kapi-vim = pkgs.kapi-vim.override { enable_haskell = true; enable_lean = true; };

      inherit (pkgs)
        direnv

        nixpkgs-fmt
        nixd

        docker
        docker-buildx

        cmake
        pkg-config

        # networking tools
        tcpdump
        wireguard-tools
        wireguard-go
        curl

        # IaaS tools
        awscli2
        gh
        git
        delta

        # tools stack
        pre-commit
        tmux
        tree
        antidote

        fzf
        fzf-git-sh
        fzf-make
        fd
        bat;
    };
  };

  programs = {
    home-manager.enable = true;

    bash = {
      enable = true;
      profileExtra = "exec zsh -l";
    };

    zsh = {
      enable = true;
      enableCompletion = false;
      history = {
        expireDuplicatesFirst = true;
        ignoreAllDups = true;
      };
      initExtraFirst = ''
        # powerlevel10k prompt cache
        if [[ -r "${config.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "${config.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';
      initExtra = ''
        source ${config.xdg.configHome}/zsh/zshrc
      '';
      envExtra = ''
        setopt no_global_rcs
        ANTIDOTE=${pkgs.antidote}/share/antidote;
        ZSH=${pkgs.zsh}/share/zsh;
      '';
    };

    tmux = {
      enable = true;
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "xterm-256color";
      mouse = true;
      keyMode = "vi";
      newSession = true;
      plugins = with pkgs.tmuxPlugins; [
        sensible
        resurrect
        { plugin = continuum; extraConfig = "set -g @continuum-restore 'off'"; }
        dracula
      ];
      extraConfig = ''
        set -wg mode-style bg=#c6c8d1,fg=#33374c
        set -g pane-border-status top

        bind '"' split-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"
        bind-key & kill-window
        bind-key x kill-pane

        set -s set-clipboard external
        bind -Tcopy-mode MouseDragEnd1Pane send -X copy-selection-no-clear 'xsel -i'
      '';
    };

    emacs = {
      enable = true;
      extraPackages = epkgs: with epkgs; [
        lsp-mode
        proof-general
      ];
    };
  };

  xdg.configFile = {
    "zsh".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/zsh";
    "wezterm".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/wezterm";
    "alacritty".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/alacritty";
    "git".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/git";
    "emacs".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/emacs";
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/kapi-vim";
  };

  home = {
    sessionVariables = {
      WEZTERM_CONFIG_FILE = "${config.home.homeDirectory}/.config/wezterm/wezterm.lua";
    };
  };
}
