{ config, pkgs, lib, ... }:
let cfg = config.modules.shells; in
{
  options.modules.shells = {
    enable = lib.mkEnableOption "Custom Zsh setup";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      direnv = {
        enable = true;
        enableBashIntegration = false;
        enableZshIntegration = false;
        nix-direnv.enable = true;
        config = {
          hide_env_diff = true;
        };
      };

      bash = {
        enable = true;
        enableCompletion = true;
        historyControl = [ "erasedups" ];
      };

      zsh = {
        enable = true;
        enableCompletion = false;
        history = {
          expireDuplicatesFirst = true;
          ignoreAllDups = true;
        };
        antidote.enable = true;
        initContent =
          let
            initExtra = ''
              source ${config.xdg.configHome}/zsh/zshrc
            '';
          in
          pkgs.lib.mkMerge [ initExtra ];
        envExtra = ''
          setopt no_global_rcs
          ANTIDOTE=${pkgs.antidote}/share/antidote;
          ZSH=${pkgs.zsh}/share/zsh;
        '';
      };
    };
    xdg = {
      enable = true;
      configFile =
        let
          zshSrc = "${config.home.homeDirectory}/Projects/kapi-sysconf/modules/shells/zsh";
          mkLink = name: {
            "zsh/${name}".source = config.lib.file.mkOutOfStoreSymlink "${zshSrc}/${name}";
          };
        in
        # Per-file (not whole-dir) symlinks so home-manager's zsh module can
        # also place its generated .zshrc / .zshenv under ~/.config/zsh.
        lib.mkMerge (map mkLink [ "zshrc" "zsh_plugins.txt" "zsh_plugins.zsh" ]);
    };
  };
}

