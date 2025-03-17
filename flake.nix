{
  description = "My nixos homelab";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    hardware.url = "github:NixOS/nixos-hardware/master";
    # impermanence.url = "github:nix-community/impermanence";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative partitioning and formatting
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Secrets management. See ./docs/secretsmgmt.md
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Theming
    stylix.url = "github:danth/stylix/release-24.11";

    # index packages / used for command-not-found and comma
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      systems = [
        "x86_64-linux"
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
      homeConfigurations."jakobe" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./home/jakobe/wsl
          inputs.stylix.homeManagerModules.stylix

        ];
        extraSpecialArgs = {
          inherit inputs outputs;
          lib = extendedLib; # Use the extended library
          hostSpec = {
            username = "jakobe";
            hostName = "wsl-host";
            handle = "Jakob Edvardsson";
            email = "jakob@edvardsson.tech";
          };
        };
      };
    };
}
