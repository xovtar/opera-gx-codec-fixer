#!/usr/bin/env bash
set -Eeuo pipefail

REPO='nwjs-ffmpeg-prebuilt/nwjs-ffmpeg-prebuilt'
DEST='/usr/lib/x86_64-linux-gnu/opera-gx-stable/libffmpeg.so'
API="https://api.github.com/repos/${REPO}/releases?per_page=100"

fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }
command -v python3 >/dev/null || fail 'python3 is required.'
command -v curl >/dev/null || fail 'curl is required.'
command -v unzip >/dev/null || fail 'unzip is required.'
command -v opera-gx >/dev/null || fail 'Opera GX was not found.'
[[ -f "$DEST" ]] || fail "Opera GX library not found: $DEST"

# Prefer the actual Chromium version embedded in the browser executable.
BROWSER_DIR="$(dirname "$DEST")"
CHROMIUM_VERSION="$(find "$BROWSER_DIR" -maxdepth 1 -type f -name 'opera*' -print0 | xargs -0 -r strings 2>/dev/null | grep -Eo '(Chrome|Chromium)/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1 | cut -d/ -f2 || true)"
if [[ -z "$CHROMIUM_VERSION" ]]; then
  printf 'Could not automatically verify Opera GX Chromium version.\n'
  printf 'Open opera://version in Opera GX and enter the Chromium version shown there.\n'
  read -r -p 'Chromium version (e.g. 153.0.8010.55): ' CHROMIUM_VERSION
fi
[[ "$CHROMIUM_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail 'Invalid Chromium version.'
MAJOR="${CHROMIUM_VERSION%%.*}"
printf 'Opera GX Chromium: %s\n' "$CHROMIUM_VERSION"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
curl -fsSL --retry 3 "$API" -o "$tmp/releases.json" || fail 'Could not retrieve GitHub releases.'

# Select only a release whose declared Chromium major matches Opera's.
# Choose the newest matching-major release returned by GitHub.
python3 - "$tmp/releases.json" "$MAJOR" > "$tmp/selection" <<'PY'
import json, re, sys
releases = json.load(open(sys.argv[1]))
major = int(sys.argv[2])
for rel in releases:
    body = rel.get('body') or ''
    match = re.search(r'Chromium\s+(\d+\.\d+\.\d+\.\d+)', body, re.I)
    if not match or int(match.group(1).split('.')[0]) != major:
        continue
    tag = rel.get('tag_name', '')
    for asset in rel.get('assets', []):
        if asset.get('name') == f'{tag}-linux-x64.zip':
            print(tag)
            print(match.group(1))
            print(asset['browser_download_url'])
            sys.exit(0)
sys.exit(1)
PY
[[ -s "$tmp/selection" ]] || fail "No matching Chromium $MAJOR Linux x64 release found in the latest 100 GitHub releases. Opera library unchanged."
mapfile -t chosen < "$tmp/selection"
TAG="${chosen[0]}"; BUILT_FOR="${chosen[1]}"; URL="${chosen[2]}"
printf 'Candidate: NW.js FFmpeg %s (Chromium %s)\n' "$TAG" "$BUILT_FOR"
if [[ "${BUILT_FOR%.*}" != "${CHROMIUM_VERSION%.*}" ]]; then
  printf 'WARNING: Chromium build versions differ; only the major version matches.\n'
fi
read -r -p 'Proceed with this unofficial codec replacement? [y/N] ' confirm
[[ "$confirm" =~ ^[Yy]$ ]] || fail 'Cancelled; no files changed.'

curl -fL --retry 3 "$URL" -o "$tmp/codec.zip" || fail 'Download failed.'
unzip -tq "$tmp/codec.zip" >/dev/null || fail 'Archive validation failed.'
unzip -jq "$tmp/codec.zip" 'libffmpeg.so' -d "$tmp" >/dev/null || fail 'Archive does not contain libffmpeg.so.'
file "$tmp/libffmpeg.so" | grep -q 'ELF 64-bit.*x86-64' || fail 'Unexpected binary architecture.'

if pgrep -f '/opera-gx-stable/opera|/opera-gx-stable/opera-gx' >/dev/null; then
  fail 'Opera GX appears to be running. Close it completely and run again.'
fi
backup="${DEST}.backup.$(date +%Y%m%d-%H%M%S)"
sudo cp -a "$DEST" "$backup" || fail 'Backup failed.'
sudo install -o root -g root -m 644 "$tmp/libffmpeg.so" "$DEST" || fail "Install failed; restore from $backup"
printf '\nCodec installed. Backup: %s\nRestart Opera GX and test video playback.\n' "$backup"
