{ dotfiles
, username
, stateVersion
, lite ? false
, ...
}:
{ config
, pkgs
, ...
}:

{
  imports = [ ../modules/shells ];
  modules.shells = {
    enable = true;
  };

  home = {
    username = username;
    homeDirectory = pkgs.lib.mkMerge [
      (pkgs.lib.mkIf pkgs.stdenv.isDarwin "/Users/${username}")
      (pkgs.lib.mkIf pkgs.stdenv.isLinux "/home/${username}")
    ];
    stateVersion = stateVersion;

    packages = builtins.attrValues {
      kapi-vim = pkgs.kapi-vim.override {
        enable_haskell = ! lite;
        enable_lean = ! lite;
        enable_typst = ! lite;
      };

      inherit (pkgs)
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

        fzf
        fzf-git-sh
        fzf-make
        fd
        bat
        gemini-cli;
    };

    sessionVariables = pkgs.lib.optionalAttrs (! lite) {
      WEZTERM_CONFIG_FILE = "${config.xdg.configHome}/wezterm/wezterm.lua";
    };
  };

  programs = {
    home-manager.enable = true;
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
        evil
      ];
    };
  };

  xdg.configFile = {
    "git".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/git";
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/kapi-vim";
  } // pkgs.lib.optionalAttrs (! lite) {
    "wezterm".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/wezterm";
    "alacritty".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/alacritty";
    "emacs".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/emacs";
  };
}
