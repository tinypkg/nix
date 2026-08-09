#!/usr/bin/env bash
set -uo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo_root"

mode=${1:-}
if [[ -z $mode ]]; then
  echo "usage: $0 <evaluate|build> [package ...]" >&2
  exit 2
fi
shift

passed=0
failed=()

warn_and_skip() {
  local item=$1
  failed+=("$item")
  if [[ ${GITHUB_ACTIONS:-} == "true" ]]; then
    echo "::warning title=Package check skipped::$item failed; continuing with the remaining packages"
  else
    echo "warning: $item failed; continuing with the remaining packages" >&2
  fi
}

write_summary() {
  local title=$1

  [[ -n ${GITHUB_STEP_SUMMARY:-} ]] || return 0

  {
    echo "### $title"
    echo
    echo "- Passed: $passed"
    echo "- Failed and skipped: ${#failed[@]}"
    if ((${#failed[@]} > 0)); then
      echo
      for item in "${failed[@]}"; do
        echo "- \`$item\`"
      done
    fi
    echo
  } >>"$GITHUB_STEP_SUMMARY"
}

case "$mode" in
evaluate)
  if ! package_matrix=$(
    nix eval --json .#packages \
      --apply 'systems: builtins.mapAttrs (_: packages: builtins.attrNames packages) systems'
  ); then
    echo "unable to enumerate flake package outputs" >&2
    exit 1
  fi

  while IFS=$'\t' read -r system package; do
    item="$system#$package"
    if nix eval --raw ".#packages.\"$system\".\"$package\".drvPath" >/dev/null; then
      ((passed += 1))
    else
      warn_and_skip "$item"
    fi
  done < <(jq -r 'to_entries[] | .key as $system | .value[] | [$system, .] | @tsv' <<<"$package_matrix")

  write_summary "Package evaluation"
  ;;
build)
  if (($# == 0)); then
    echo "build mode requires at least one package" >&2
    exit 2
  fi

  for package in "$@"; do
    if nix build --no-link ".#$package"; then
      ((passed += 1))
    else
      warn_and_skip "$package"
    fi
  done

  write_summary "Representative package builds"
  ;;
*)
  echo "unknown mode: $mode" >&2
  exit 2
  ;;
esac

exit 0
