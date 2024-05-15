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
      envExtra = ''
        ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh";
        ZSH_CACHE_DIR="${config.home.homeDirectory}/.cache/oh-my-zsh";
      '';
    };

    git = {
      enable = true;
      delta = {
        enable = true;
      };
      extraConfig = {
        core.editor = "nvim";
        url = {
          "git@github.com" = {
            insteadOf = "https://github.com";
          };
        };
        user = {
          email = "15379156+potsrevennil@users.noreply.github.com ";
          name = "Thing-han, Lim";
        };
        commit.template = "${config.home.homeDirectory}/.config/git/gitmessage_global";

        delta = {
          navigate = true;
          side-by-side = true;
        };
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
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
      WEZTERM_CONFIG_FILE = "${config.home.homeDirectory}/.config/wezterm/wezterm.lua";
    };
    file = {
      ".config/zsh/zshrc".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/zshrc";
      ".config/wezterm/wezterm.lua".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/wezterm.lua";
      ".config/alacritty/alacritty.yml".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/alacritty.yml";
      ".config/git/gitmessage_global".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/git/gitmessage_global";
    };
  };
}
