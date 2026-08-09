#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
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

package_file() {
  printf '%s/packages/%s/source.json\n' "$repo_root" "$1"
}

latest_version() {
  local package=$1
  local file method
  file=$(package_file "$package")
  method=$(jq -r '.update.method' "$file")

  case "$method" in
  github)
    local repo tag suffix
    repo=$(jq -r '.update.repo' "$file")
    tag=$(curl --fail --silent --show-error --location "${github_headers[@]}" \
      "https://api.github.com/repos/$repo/releases/latest" | jq -er '.tag_name')
    tag=${tag#v}
    suffix=$(jq -r '.update.stripSuffix // ""' "$file")
    if [[ -n $suffix ]]; then tag=${tag%"$suffix"}; fi
    printf '%s\n' "$tag"
    ;;
  pypi)
    local project
    project=$(jq -r '.update.project' "$file")
    curl --fail --silent --show-error --location \
      "https://pypi.org/pypi/$project/json" | jq -er '.info.version'
    ;;
  yaml)
    local url
    url=$(jq -r '.update.url' "$file")
    curl --fail --silent --show-error --location "$url" |
      sed -nE 's/^version:[[:space:]]*["'\'']?([^"'\'']+)["'\'']?[[:space:]]*$/\1/p' |
      head -n1
    ;;
  json)
    local url selector
    url=$(jq -r '.update.url' "$file")
    selector=$(jq -r '.update.selector' "$file")
    curl --fail --silent --show-error --location "$url" | jq -er "$selector" | sed 's/^v//'
    ;;
  html)
    local url regex
    url=$(jq -r '.update.url' "$file")
    regex=$(jq -r '.update.versionRegex' "$file")
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
  local file current latest transform old_url_version new_url_version
  file=$(package_file "$package")
  current=$(jq -r '.version' "$file")

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

  transform=$(jq -r '.update.urlVersionTransform // "identity"' "$file")
  old_url_version=$current
  new_url_version=$latest
  if [[ $transform == "dot-beta" ]]; then
    old_url_version=${old_url_version/.beta./-beta.}
    new_url_version=${new_url_version/.beta./-beta.}
  fi

  echo "$package: $current -> $latest"
  while IFS= read -r system; do
    local old_url new_url replace_from replace_to prefetch hash old_name new_name artifact
    old_url=$(jq -r --arg system "$system" '.sources[$system].url' "$file")
    new_url=${old_url//"$old_url_version"/"$new_url_version"}

    replace_from=$(jq -r '.update.urlReplaceFrom // ""' "$file")
    replace_to=$(jq -r '.update.urlReplaceTo // ""' "$file")
    if [[ -n $replace_from ]]; then new_url=${new_url//"$replace_from"/"$replace_to"}; fi

    prefetch=$(nix store prefetch-file --json "$new_url")
    hash=$(jq -er '.hash' <<<"$prefetch")
    old_name=$(jq -r --arg system "$system" '.sources[$system].fileName // ""' "$file")
    new_name=${old_name//"$old_url_version"/"$new_url_version"}

    artifact=$(jq -cn --arg url "$new_url" --arg hash "$hash" --arg fileName "$new_name" \
      '{url: $url, hash: $hash} + (if $fileName == "" then {} else {fileName: $fileName} end)')
    jq --arg system "$system" --arg version "$latest" --argjson artifact "$artifact" \
      '.version = $version | .sources[$system] = $artifact' \
      "$file" >"$file.next"
    mv "$file.next" "$file"
  done < <(jq -r '.sources | keys[]' "$file")

  jq --sort-keys . "$file" >"$file.sorted"
  mv "$file.sorted" "$file"
}

if [[ -n $package_filter ]]; then
  if [[ ! -f "$(package_file "$package_filter")" ]]; then
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
  done < <(git -C "$repo_root" ls-files 'packages/*/source.json' |
    sed -nE 's#^packages/([^/]+)/source\.json$#\1#p' |
    sort)
  if ((failures)); then
    echo "warning: $failures package update checks failed" >&2
  fi
fi
