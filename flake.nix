{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:JakobEdvardsson/nixos-hardware/master";

    nur.url = "github:nix-community/NUR";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-hardware,
    nur,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      legion = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        # > Our main nixos configuration file <
        modules = [
          ./hosts/legion
          #nixos-hardware.nixosModules.lenovo-legion-16achg6-hybrid

          home-manager.nixosModules.home-manager
          {
            #home-manager.useGlobalPkgs = true;
            #home-manager.useUserPackages = true;
            home-manager.users.jakobe = {
              imports = [
                nur.nixosModules.nur
                ./hosts/legion/home.nix
              ];
            };

            home-manager.extraSpecialArgs = {inherit inputs outputs;};
          }
        ];
      };

      laptopserver = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        # > Our main nixos configuration file <
        modules = [
          ./hosts/laptopserver
          home-manager.nixosModules.home-manager
          {
            #home-manager.useGlobalPkgs = true;
            #home-manager.useUserPackages = true;
            home-manager.users.jakobe = {
              imports = [
                nur.nixosModules.nur
                ./hosts/laptopserver/home.nix
              ];
            };

            home-manager.extraSpecialArgs = {inherit inputs outputs;};
          }
        ];
      };
    };
  };
}
