# Implementation plan

1. Inventory source URLs, versions, architectures, licenses, dependencies, and
   install behavior from all 40 PKGBUILDs.
2. Implement shared Nix builders and package definitions by source format.
3. Export packages from a pinned flake and add a development shell.
4. Add structural checks, CI, update helpers, and complete user documentation.
5. Evaluate the complete flake and build representatives in a clean container.
6. Create `tinypkg/nix`, commit the verified tree, and push the default branch.

## Risks

- Prebuilt GUI binaries may load libraries dynamically; shared builders must
  patch ELF files and wrap runtime search paths.
- Some upstream URLs are mutable or architecture-specific; every source must use
  a fixed hash and accurately restricted platform metadata.
- Large proprietary applications make full matrix builds expensive; CI will
  evaluate all packages and build a format-representative subset.
