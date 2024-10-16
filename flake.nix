{
  description = "NixOS-Hyprland";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-24.05";
    #wallust.url = "git+https://codeberg.org/explosion-mental/wallust?ref=dev";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1"; # hyprland development

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    fine-cmdline = {
      url = "github:VonHeikemen/fine-cmdline.nvim";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      ...
    }@inputs:
    let

      system = "x86_64-linux";
      lib = nixpkgs.lib;
      username = "jakobe";
      host = "nixos";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

      pkgs-stable = import nixpkgs-stable {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      nixosConfigurations = {
        "${host}" = lib.nixosSystem {
          specialArgs = {
            inherit system;
            inherit username;
            inherit host;
            inherit pkgs-stable;
            inherit inputs;
          };
          modules = [
            ./hosts/${host}/config.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.jakobe = {
                imports = [
                  ./home-manager/home.nix
                ];
              };

              home-manager.extraSpecialArgs = {
                inherit pkgs;
              };
            }
          ];
        };
      };
    };
}
