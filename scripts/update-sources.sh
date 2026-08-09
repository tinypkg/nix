#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
sources_file="$repo_root/packages/sources.json"
updates_file="$repo_root/packages/update.json"
package_filter=${1:-}
version_override=${2:-}

if [[ -n $version_override && -z $package_filter ]]; then
  echo "a version override requires a package name" >&2
  exit 2
fi

github_headers=(-H "Accept: application/vnd.github+json")
if [[ -n ${GH_TOKEN:-} ]]; then
  github_headers+=(-H "Authorization: Bearer $GH_TOKEN")
fi

latest_version() {
  local package=$1
  local method
  method=$(jq -r --arg package "$package" '.[$package].method' "$updates_file")

  case "$method" in
  github)
    local repo tag suffix
    repo=$(jq -r --arg package "$package" '.[$package].repo' "$updates_file")
    tag=$(curl --fail --silent --show-error --location "${github_headers[@]}" \
      "https://api.github.com/repos/$repo/releases/latest" | jq -er '.tag_name')
    tag=${tag#v}
    suffix=$(jq -r --arg package "$package" '.[$package].stripSuffix // ""' "$updates_file")
    if [[ -n $suffix ]]; then tag=${tag%"$suffix"}; fi
    printf '%s\n' "$tag"
    ;;
  pypi)
    local project
    project=$(jq -r --arg package "$package" '.[$package].project' "$updates_file")
    curl --fail --silent --show-error --location \
      "https://pypi.org/pypi/$project/json" | jq -er '.info.version'
    ;;
  yaml)
    local url
    url=$(jq -r --arg package "$package" '.[$package].url' "$updates_file")
    curl --fail --silent --show-error --location "$url" |
      sed -nE 's/^version:[[:space:]]*["'\'']?([^"'\'']+)["'\'']?[[:space:]]*$/\1/p' |
      head -n1
    ;;
  json)
    local url selector
    url=$(jq -r --arg package "$package" '.[$package].url' "$updates_file")
    selector=$(jq -r --arg package "$package" '.[$package].selector' "$updates_file")
    curl --fail --silent --show-error --location "$url" | jq -er "$selector" | sed 's/^v//'
    ;;
  html)
    local url regex
    url=$(jq -r --arg package "$package" '.[$package].url' "$updates_file")
    regex=$(jq -r --arg package "$package" '.[$package].versionRegex' "$updates_file")
    curl --fail --silent --show-error --location "$url" |
      grep -oE "$regex" |
      sed -E 's#^/releases/|/$##g' |
      sort -Vu |
      tail -n1
    ;;
  manual)
    return 3
    ;;
  *)
    echo "unknown update method '$method' for $package" >&2
    return 2
    ;;
  esac
}

update_package() {
  local package=$1
  local current latest transform old_url_version new_url_version
  current=$(jq -r --arg package "$package" '.[$package].version' "$sources_file")

  if [[ -n $version_override ]]; then
    latest=$version_override
  elif latest=$(latest_version "$package"); then
    :
  else
    local status=$?
    if [[ $status -eq 3 ]]; then
      echo "$package: manual update strategy, skipped"
      return 0
    fi
    echo "$package: unable to detect latest version" >&2
    return "$status"
  fi

  if [[ -z $latest || $latest == "null" ]]; then
    echo "$package: upstream returned an empty version" >&2
    return 1
  fi
  if [[ $latest == "$current" && -z $version_override ]]; then
    echo "$package: already at $current"
    return 0
  fi

  transform=$(jq -r --arg package "$package" '.[$package].urlVersionTransform // "identity"' "$updates_file")
  old_url_version=$current
  new_url_version=$latest
  if [[ $transform == "dot-beta" ]]; then
    old_url_version=${old_url_version/.beta./-beta.}
    new_url_version=${new_url_version/.beta./-beta.}
  fi

  echo "$package: $current -> $latest"
  while IFS= read -r system; do
    local old_url new_url replace_from replace_to prefetch hash old_file new_file artifact
    old_url=$(jq -r --arg package "$package" --arg system "$system" \
      '.[$package].sources[$system].url' "$sources_file")
    new_url=${old_url//"$old_url_version"/"$new_url_version"}

    replace_from=$(jq -r --arg package "$package" '.[$package].urlReplaceFrom // ""' "$updates_file")
    replace_to=$(jq -r --arg package "$package" '.[$package].urlReplaceTo // ""' "$updates_file")
    if [[ -n $replace_from ]]; then new_url=${new_url//"$replace_from"/"$replace_to"}; fi

    prefetch=$(nix store prefetch-file --json "$new_url")
    hash=$(jq -er '.hash' <<<"$prefetch")
    old_file=$(jq -r --arg package "$package" --arg system "$system" \
      '.[$package].sources[$system].fileName // ""' "$sources_file")
    new_file=${old_file//"$old_url_version"/"$new_url_version"}

    artifact=$(jq -cn --arg url "$new_url" --arg hash "$hash" --arg file "$new_file" \
      '{url: $url, hash: $hash} + (if $file == "" then {} else {fileName: $file} end)')
    jq --arg package "$package" --arg system "$system" --arg version "$latest" \
      --argjson artifact "$artifact" \
      '.[$package].version = $version | .[$package].sources[$system] = $artifact' \
      "$sources_file" >"$sources_file.next"
    mv "$sources_file.next" "$sources_file"
  done < <(jq -r --arg package "$package" '.[$package].sources | keys[]' "$sources_file")
}

if [[ -n $package_filter ]]; then
  if ! jq -e --arg package "$package_filter" 'has($package)' "$updates_file" >/dev/null; then
    echo "unknown package: $package_filter" >&2
    exit 2
  fi
  update_package "$package_filter"
else
  failures=0
  while IFS= read -r package; do
    if ! update_package "$package"; then
      echo "warning: update failed for $package; continuing" >&2
      failures=$((failures + 1))
    fi
  done < <(jq -r 'keys[]' "$updates_file")
  if ((failures)); then
    echo "warning: $failures package update checks failed" >&2
  fi
fi

jq --sort-keys . "$sources_file" >"$sources_file.sorted"
mv "$sources_file.sorted" "$sources_file"
