#!/usr/bin/env bash
set -euo pipefail

repo_root=${1:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}
cd "$repo_root"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git ls-files 'packages/*/source.json' \
    | sed -nE 's#^packages/([^/]+)/source\.json$#\1#p' \
    | sort >"$tmp_dir/packages"
else
  # Nix check inputs do not contain .git; enumerate the archived package tree.
  for source_file in packages/*/source.json; do
    package_dir=${source_file%/source.json}
    basename "$package_dir"
  done | sort >"$tmp_dir/packages"
fi

if ! diff -u tests/expected-packages.txt "$tmp_dir/packages"; then
  echo "package directories differ from the expected inventory" >&2
  exit 1
fi

while IFS= read -r package; do
  metadata_file="packages/$package/package.nix"
  source_file="packages/$package/source.json"

  if [[ ! -s "$metadata_file" ]]; then
    echo "$package is missing package.nix" >&2
    exit 1
  fi
  jq -e . "$source_file" >/dev/null
  jq -e '.update.method | type == "string" and length > 0' "$source_file" >/dev/null

  if jq -e '
    any(
      .sources[];
      (.url | startswith("https://") | not)
      or ((.hash // .sha256 // .md5 // "") | test("^(SKIP)?$"))
    )
  ' "$source_file" >/dev/null; then
    echo "$package has a non-HTTPS source or missing fixed hash" >&2
    exit 1
  fi

  if ! grep -Fq "| \`$package\` |" README.md; then
    echo "README is missing $package" >&2
    exit 1
  fi
done <tests/expected-packages.txt

echo "structural checks passed for $(wc -l <tests/expected-packages.txt) packages"
