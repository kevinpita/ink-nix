#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# An optional version argument permits testing or selecting a release.
version=${1:-$(gh api repos/borghei/ink/releases/latest --jq .tag_name)}
version=${version#v}
if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid release version: $version" >&2
  exit 1
fi
if [[ -f sources.json ]] && [[ $(jq -r .version sources.json) == "$version" ]]; then
  echo "ink $version is current"
  exit 0
fi

# Download both assets before replacing the manifest. Nix verifies these hashes
# again when the package is built.
x64=$(nix store prefetch-file --json "https://github.com/borghei/ink/releases/download/v$version/ink-linux-amd64" | jq -er .hash)
arm64=$(nix store prefetch-file --json "https://github.com/borghei/ink/releases/download/v$version/ink-linux-arm64" | jq -er .hash)
tmp=$(mktemp ./sources.json.XXXXXX)
trap 'rm -f "$tmp"' EXIT
jq -n --arg version "$version" --arg x64 "$x64" --arg arm64 "$arm64" '{
  version: $version,
  sources: {
    "x86_64-linux": {asset: "ink-linux-amd64", hash: $x64},
    "aarch64-linux": {asset: "ink-linux-arm64", hash: $arm64}
  }
}' > "$tmp"
mv "$tmp" sources.json
echo "Updated ink to $version"
