{
  description = "Reusable Fedora dotfiles managed by Home Manager";

  inputs = {
    # Nix 2.27+ can include checked-out Git submodules in the root flake source.
    self.submodules = true;

    # Use shallow HTTPS Git inputs instead of the GitHub API shorthand. This
    # avoids unauthenticated API rate limits while flake.lock still pins exact
    # commits and content hashes.
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?ref=nixos-26.05&shallow=1";

    home-manager = {
      url = "git+https://github.com/nix-community/home-manager?ref=release-26.05&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      mkFedoraHome =
        {
          username,
          homeDirectory ? "/home/${username}",
          dotfilesDirectory ? null,
        }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit username homeDirectory dotfilesDirectory;
          };
          modules = [ ./nix/hosts/fedora.nix ];
        };
      sorasukaHome = mkFedoraHome {
        username = "sorasuka";
      };
    in
    {
      # Keep the original profile as a stable direct flake output. Other users
      # are instantiated through lib.mkFedoraHome by install.sh.
      homeConfigurations."sorasuka@fedora" = sorasukaHome;

      lib.mkFedoraHome = mkFedoraHome;

      checks.${system}.home-activation = sorasukaHome.activationPackage;
    };
}
