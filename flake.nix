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
  	};

  outputs = 
	inputs@{ self,nixpkgs,nixpkgs-stable,home-manager, ... }:
    	let
      system = "x86_64-linux";
      host = "nixos";
      username = "jakobe";

    pkgs = import nixpkgs {
       	inherit system;
       	config = {
       	allowUnfree = true;
       	};
      };
    in
      {
	nixosConfigurations = {
      "${host}" = nixpkgs.lib.nixosSystem rec {
		specialArgs = { 
			inherit system;
			inherit inputs;
			inherit username;
			inherit host;
			};
	   		modules = [ 
			  ./hosts/${host}/config.nix
		           home-manager.nixosModules.home-manager {
            			#home-manager.useGlobalPkgs = true;
            			#home-manager.useUserPackages = true;
            			home-manager.users.jakobe = {
              			  imports = [
                		    ./home-manager/home.nix
              			  ];
            			};

            		       #home-manager.extraSpecialArgs = {inherit inputs outputs;};
         		   }
			];
		     };
		};
	};
}
