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
          toolingEnabled = builtins.elem system (import systems);
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          packageDirectoryEntries = builtins.readDir ./packages;
          packageNames = builtins.filter (name: packageDirectoryEntries.${name} == "directory") (
            builtins.attrNames packageDirectoryEntries
          );
          packageSpecs = builtins.listToAttrs (
            map (
              name:
              let
                packageDirectory = ./packages + "/${name}";
              in
              {
                inherit name;
                value = (import (packageDirectory + "/package.nix")) // {
                  inherit packageDirectory;
                  sourceInfo = builtins.fromJSON (builtins.readFile (packageDirectory + "/source.json"));
                };
              }
            ) packageNames
          );
          mkPackage = import ./lib/mk-package.nix { inherit pkgs system; };
          available = pkgs.lib.filterAttrs (
            _: spec: builtins.hasAttr system spec.sourceInfo.sources
          ) packageSpecs;
          packageSet = pkgs.lib.mapAttrs (
            name: spec:
            let
              completeSpec = spec // {
                inherit name;
              };
              genericPackage = mkPackage completeSpec;
              customBuilder = spec.packageDirectory + "/build.nix";
            in
            if builtins.pathExists customBuilder then
              import customBuilder {
                inherit pkgs completeSpec genericPackage;
              }
            else
              genericPackage
          ) available;
          repositoryCheck = pkgs.writeShellApplication {
            name = "tinypkg-repository-check";
            runtimeInputs = [ pkgs.jq ];
            text = builtins.readFile ./scripts/check.sh;
          };
        in
        {
          packages = packageSet;

          checks = pkgs.lib.optionalAttrs toolingEnabled {
            repository = pkgs.runCommand "tinypkg-repository-check" { } ''
              ${repositoryCheck}/bin/tinypkg-repository-check ${self}
              touch $out
            '';
          };

          devshells = pkgs.lib.optionalAttrs toolingEnabled {
            default = {
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
          };

          treefmt = pkgs.lib.mkIf toolingEnabled {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
            programs.shfmt.enable = true;
          };
        };
    };
}
