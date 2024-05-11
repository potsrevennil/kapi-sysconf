{ pkgs, ... }:

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

        # tools stack
        git
        pre-commit
        tmux
        tree
        wezterm

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
      oh-my-zsh = {
        enable = true;
        plugins = [ "sudo" "git" "colored-man-pages" "tmux" ];
        theme = "random";
        extraConfig = ''
          DISABLE_MAGIC_FUNCTIONS=true
        '';
      };
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

    zellij = {
      enable = true;
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

  home = {
    sessionVariables = {
      WEZTERM_CONFIG_FILE = "~/.config/wezterm/wezterm.lua";
    };
    file = {
      ".config/zsh/zshrc".source = ./zshrc;
      ".config/wezterm/wezterm.lua".source = ./wezterm.lua;
      ".config/alacritty/alacritty.yml".source = ./alacritty.yml;
      ".config/zellij/config.kdl".source = ./zellij.kdl;
      ".config/zellij/layouts/default.kdl".source = ./zellij-default-layout.kdl;
    };
  };
}
