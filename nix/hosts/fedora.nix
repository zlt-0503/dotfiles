{
  config,
  dotfilesDirectory,
  homeDirectory,
  username,
  ...
}:
{
  imports = [
    ../modules/desktop.nix
    ../modules/packages.nix
    ../modules/shell.nix
    ../../config/nvim/nix/home-manager.nix
  ];

  home = {
    inherit username homeDirectory;
    stateVersion = "26.05";
    sessionPath = [ "$HOME/.local/bin" ];
  };

  xdg.enable = true;
  targets.genericLinux.enable = true;

  programs.home-manager.enable = true;

  sorasuka.neovim = {
    enable = true;
    source =
      if dotfilesDirectory == null then
        null
      else
        "${dotfilesDirectory}/config/nvim";
  };

  assertions = [
    {
      assertion = username != "";
      message = "The Fedora home profile requires a non-empty username.";
    }
    {
      assertion = homeDirectory != "" && builtins.substring 0 1 homeDirectory == "/";
      message = "The Fedora home profile requires an absolute home directory.";
    }
    {
      assertion = config.home.username == username && config.home.homeDirectory == homeDirectory;
      message = "The evaluated Home Manager identity differs from the requested user.";
    }
  ];
}
