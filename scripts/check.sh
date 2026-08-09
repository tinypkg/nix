#!/usr/bin/env bash
set -euo pipefail

repo_root=${1:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}
cd "$repo_root"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

jq -e . packages/sources.json >/dev/null
jq -r 'keys[]' packages/sources.json >"$tmp_dir/sources"
jq -e . packages/update.json >/dev/null
jq -r 'keys[]' packages/update.json >"$tmp_dir/updates"

sed -nE 's/^  ([a-z0-9-]+) = \{$/\1/p' packages/metadata.nix |
  sort >"$tmp_dir/metadata"

for list in "$tmp_dir/sources" "$tmp_dir/metadata" "$tmp_dir/updates" tests/expected-packages.txt; do
  if ! diff -u tests/expected-packages.txt "$list"; then
    echo "package inventories differ" >&2
    exit 1
  fi
done

if jq -e '
  any(
    .[].sources[];
    (.url | startswith("https://") | not)
    or ((.sha256 // .md5 // "") | test("^(SKIP)?$") )
  )
' packages/sources.json >/dev/null; then
  echo "every source must use HTTPS and a fixed hash" >&2
  exit 1
fi

while IFS= read -r package; do
  if ! grep -Fq "| \`$package\` |" README.md; then
    echo "README is missing $package" >&2
    exit 1
  fi
done <tests/expected-packages.txt

echo "structural checks passed for $(wc -l <tests/expected-packages.txt) packages"
