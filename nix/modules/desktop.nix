{
  lib,
  pkgs,
  ...
}:
let
  mkHyprScript =
    {
      name,
      source,
      runtimeInputs ? [ ],
    }:
    pkgs.writeShellScriptBin name ''
      ${lib.optionalString (runtimeInputs != [ ]) ''
        export PATH="${lib.makeBinPath runtimeInputs}:$PATH"
      ''}
      ${builtins.readFile source}
    '';

  hideWindow = mkHyprScript {
    name = "hide-window";
    source = ../../config/hypr/scripts/hide-window.sh;
  };
  minimizeWindow = mkHyprScript {
    name = "minimize-window";
    source = ../../config/hypr/scripts/minimize-window.sh;
    runtimeInputs = [ pkgs.jq ];
  };
  smartLaunch = mkHyprScript {
    name = "smart-launch";
    source = ../../config/hypr/scripts/smart-launch.sh;
    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
    ];
  };
  tmuxTerminal = mkHyprScript {
    name = "tmux-terminal";
    source = ../../config/hypr/scripts/tmux-terminal.sh;
    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
      pkgs.tmux
    ];
  };
  toggleDropdown = mkHyprScript {
    name = "toggle-dropdown";
    source = ../../config/hypr/scripts/toggle-dropdown.sh;
    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
    ];
  };
  toggleHidden = mkHyprScript {
    name = "toggle-hidden";
    source = ../../config/hypr/scripts/toggle-hidden.sh;
  };
  toggleMonitor = mkHyprScript {
    name = "toggle-monitor";
    source = ../../config/hypr/scripts/toggle-monitor.sh;
    runtimeInputs = [
      pkgs.btop
      pkgs.coreutils
      pkgs.procps
    ];
  };
  appMenu = mkHyprScript {
    name = "app-menu";
    source = ../../config/hypr/scripts/app-menu.sh;
    runtimeInputs = [ pkgs.wofi ];
  };
  brightness = mkHyprScript {
    name = "brightness";
    source = ../../config/hypr/scripts/brightness.sh;
    runtimeInputs = [ pkgs.brightnessctl ];
  };
  pamixerVolume = mkHyprScript {
    name = "pamixer-volume";
    source = ../../config/hypr/scripts/pamixer-volume.sh;
    runtimeInputs = [ pkgs.pamixer ];
  };
  screenshot = mkHyprScript {
    name = "screenshot";
    source = ../../config/hypr/scripts/screenshot.sh;
    runtimeInputs = [
      pkgs.coreutils
      pkgs.grim
      pkgs.slurp
    ];
  };
in
{
  programs.kitty = {
    enable = true;
    package = null;
    shellIntegration.mode = null;
    extraConfig = builtins.readFile ../../config/kitty/kitty.conf;
  };

  xdg.configFile = {
    "hypr/hyprland.lua".source = ../../config/hypr/hyprland.lua;
    "hypr/scripts/hide-window.sh" = {
      source = "${hideWindow}/bin/hide-window";
      executable = true;
    };
    "hypr/scripts/minimize-window.sh" = {
      source = "${minimizeWindow}/bin/minimize-window";
      executable = true;
    };
    "hypr/scripts/smart-launch.sh" = {
      source = "${smartLaunch}/bin/smart-launch";
      executable = true;
    };
    "hypr/scripts/tmux-terminal.sh" = {
      source = "${tmuxTerminal}/bin/tmux-terminal";
      executable = true;
    };
    "hypr/scripts/toggle-dropdown.sh" = {
      source = "${toggleDropdown}/bin/toggle-dropdown";
      executable = true;
    };
    "hypr/scripts/toggle-hidden.sh" = {
      source = "${toggleHidden}/bin/toggle-hidden";
      executable = true;
    };
    "hypr/scripts/toggle-monitor.sh" = {
      source = "${toggleMonitor}/bin/toggle-monitor";
      executable = true;
    };
    "hypr/scripts/app-menu.sh" = {
      source = "${appMenu}/bin/app-menu";
      executable = true;
    };
    "hypr/scripts/brightness.sh" = {
      source = "${brightness}/bin/brightness";
      executable = true;
    };
    "hypr/scripts/pamixer-volume.sh" = {
      source = "${pamixerVolume}/bin/pamixer-volume";
      executable = true;
    };
    "hypr/scripts/screenshot.sh" = {
      source = "${screenshot}/bin/screenshot";
      executable = true;
    };

    "fcitx5/config".source = ../../config/fcitx5/config;
    "fcitx5/profile".source = ../../config/fcitx5/profile;
    "fcitx5/conf/chttrans.conf".source = ../../config/fcitx5/conf/chttrans.conf;
    "fcitx5/conf/classicui.conf".source = ../../config/fcitx5/conf/classicui.conf;
    "fcitx5/conf/notifications.conf".source = ../../config/fcitx5/conf/notifications.conf;
    "fcitx5/conf/pinyin.conf".source = ../../config/fcitx5/conf/pinyin.conf;
    "fcitx5/conf/punctuation.conf".source = ../../config/fcitx5/conf/punctuation.conf;
    "fcitx5/rime/default.custom.yaml".source = ../../config/fcitx5/rime/default.custom.yaml;
  };

  xdg.dataFile."fcitx5/themes/catppuccin-mocha-blue" = {
    source = ../../data/fcitx5/themes/catppuccin-mocha-blue;
    recursive = true;
  };
}
