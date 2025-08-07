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
            initExtraFirst = pkgs.lib.mkBefore ''
              # powerlevel10k prompt cache
              if [[ -r "${config.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
                source "${config.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh"
              fi
            '';
            initExtra = ''
              source ${config.xdg.configHome}/zsh/zshrc
            '';
          in
          pkgs.lib.mkMerge [ initExtraFirst initExtra ];
        envExtra = ''
          setopt no_global_rcs
          ANTIDOTE=${pkgs.antidote}/share/antidote;
          ZSH=${pkgs.zsh}/share/zsh;
        '';
      };
    };
    xdg = {
      enable = true;
      configFile = {
        "zsh".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Projects/kapi-sysconf/modules/shells/zsh";
      };
    };
  };
}

