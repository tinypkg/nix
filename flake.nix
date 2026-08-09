{
  description = "Prebuilt Linux applications maintained by tinypkg";

  inputs = {
    # Rolling nixpkgs is deliberate: prebuilt desktop applications need recent libraries.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default-linux";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      systems,
      devshell,
      treefmt-nix,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = (import systems) ++ [
        "riscv64-linux"
        "powerpc64le-linux"
      ];

      imports = [
        devshell.flakeModule
        treefmt-nix.flakeModule
      ];

      perSystem =
        { system, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          metadata = import ./packages/metadata.nix;
          sources = builtins.fromJSON (builtins.readFile ./packages/sources.json);
          mkPackage = import ./lib/mk-package.nix { inherit pkgs system; };
          available = pkgs.lib.filterAttrs (
            name: _: builtins.hasAttr system sources.${name}.sources
          ) metadata;
          packageSet = pkgs.lib.mapAttrs (
            name: spec:
            mkPackage (
              spec
              // {
                inherit name;
                sourceInfo = sources.${name};
              }
            )
          ) available;
          repositoryCheck = pkgs.writeShellApplication {
            name = "tinypkg-repository-check";
            runtimeInputs = [ pkgs.jq ];
            text = builtins.readFile ./scripts/check.sh;
          };
        in
        {
          packages = packageSet;

          checks.repository = pkgs.runCommand "tinypkg-repository-check" { } ''
            ${repositoryCheck}/bin/tinypkg-repository-check ${self}
            touch $out
          '';

          devshells.default = {
            name = "tinypkg-nix";
            motd = ''
              {bold}{14}Entering the tinypkg Nix package shell{reset}
              Run {bold}menu{reset} to list available commands.
            '';
            packages = [
              pkgs.curl
              pkgs.git
              pkgs.jq
            ];
            commands = [
              # ci
              {
                category = "ci";
                name = "flake-check";
                help = "Evaluate all flake checks";
                command = "nix flake check --all-systems";
              }
              {
                category = "ci";
                name = "repository-check";
                help = "Validate package metadata and documentation";
                command = "./scripts/check.sh";
              }

              # maintenance
              {
                category = "maintenance";
                name = "sources-update";
                help = "Update package versions and hashes from upstream";
                command = "./scripts/update-sources.sh \"$@\"";
              }
            ];
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
            programs.shfmt.enable = true;
          };
        };
    };
}
