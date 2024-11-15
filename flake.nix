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
      fine-cmdline,
      ...
    }@inputs:
    let

      system = "x86_64-linux";
      lib = nixpkgs.lib;
      username = "jakobe";
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
        "nixos" = lib.nixosSystem {
          specialArgs = {
            inherit system;
            inherit username;
            inherit pkgs-stable;
            inherit inputs;
            host = "nixos";
          };
          modules = [
            ./hosts/nixos/config.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.jakobe = {
                imports = [
                  ./home-manager/nixos.nix
                ];
              };

              home-manager.extraSpecialArgs = {
                inherit pkgs;
                inherit fine-cmdline;
                inherit pkgs-stable;
                inherit inputs;
              };
            }
          ];
        };

        "servox" = lib.nixosSystem {
          specialArgs = {
            inherit system;
            inherit username;
            inherit pkgs-stable;
            inherit inputs;
            host = "servox";
          };
          modules = [
            ./hosts/servox/config.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.jakobe = {
                imports = [
                  ./home-manager/servox.nix
                ];
              };

              home-manager.extraSpecialArgs = {
                inherit pkgs;
                inherit fine-cmdline;
                inherit pkgs-stable;
                inherit inputs;
              };
            }
          ];
        };

      };
    };
}
