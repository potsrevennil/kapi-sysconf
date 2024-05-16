{ config, pkgs, dotfiles, ... }:

{
  home = {
    packages = builtins.attrValues {
      inherit (pkgs)
        direnv

        kapi-vim
        kapi-vim-lsp
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
        slack
        git
        delta

        # tools stack
        pre-commit
        tmux
        tree
        wezterm
        oh-my-zsh

        fzf
        fzf-git-sh
        fzf-make
        fd
        bat

        libsixel;
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
      autocd = true;
      history = {
        expireDuplicatesFirst = true;
        ignoreAllDups = true;
        share = false;
      };
      syntaxHighlighting = {
        enable = true;
        highlighters = [ "main" "brackets" "pattern" "regexp" "cursor" "root" "line" ];
      };
      shellAliases = {
        ls = "ls --color";
        fman = "compgen -c | fzf | xargs man";
      };
      autosuggestion.enable = true;
      initExtra = ''
        source $HOME/.config/zsh/zshrc
        source ${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.sh
      '';
      envExtra = ''
        ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh";
        ZSH_CACHE_DIR="${config.home.homeDirectory}/.cache/oh-my-zsh";
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
        evil
      ];
      extraConfig = ''
        (require 'evil)
        (evil-mode 1)
      '';
    };
  };

  xdg.configFile = {
    "zsh".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/zsh";
    "wezterm".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/wezterm";
    "alacritty".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/alacritty";
    "git".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/git";
  };

  home = {
    sessionVariables = {
      WEZTERM_CONFIG_FILE = "${config.home.homeDirectory}/.config/wezterm/wezterm.lua";
    };
  };
}
