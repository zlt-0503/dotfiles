{ pkgs, ... }:
{
  # These are portable user tools or direct dependencies of the Hyprland
  # helper scripts. The compositor, input method, PipeWire, Kitty, and other
  # session-integrated programs remain Fedora packages.
  home.packages = with pkgs; [
    btop
    brightnessctl
    grim
    jq
    pamixer
    slurp
    wl-clipboard
    wofi
    yazi
    maple-mono."Normal-NF-CN"
  ];

  fonts.fontconfig.enable = true;

  programs.bat.enable = true;
  programs.fzf.enable = true;
}
