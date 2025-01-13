{
  description = "My nixos homelab";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # impermanence.url = "github:nix-community/impermanence";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix/release-24.11";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      systems = [
        "x86_64-linux"
        # "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Extend the library with custom functions
      extendedLib = nixpkgs.lib.extend (
        self: super: {
          custom = import ./lib { inherit (nixpkgs) lib; };
        }
      );
    in
    {
      # Enables `nix fmt` at root of repo to format all nix files
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      darwinConfigurations = {
        /*
          mac1chng = nix-darwin.lib.darwinSystem {
            specialArgs = {inherit inputs outputs;};
            modules = [./machines/mac1chng/configuration.nix];
          };
        */
      };

      nixosConfigurations = {
        legion = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
            lib = extendedLib; # Use the extended library
          };
          modules = [ ./hosts/nixos/legion ];
        };
        servox = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
            lib = extendedLib; # Use the extended library
          };
          modules = [ ./hosts/nixos/servox ];
        };
        think = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
            lib = extendedLib; # Use the extended library
          };
          modules = [ ./hosts/nixos/think ];
        };
      };
    };
}
