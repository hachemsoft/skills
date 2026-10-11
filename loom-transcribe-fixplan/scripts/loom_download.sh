#!/usr/bin/env bash
set -euo pipefail

url="${1:-}"
out_dir="${2:-/tmp/loom}"

if [[ -z "${url}" ]]; then
  echo "Usage: loom_download.sh <loom_url> [out_dir]" >&2
  exit 2
fi

mkdir -p "${out_dir}"

if ! command -v yt-dlp >/dev/null 2>&1; then
  echo "yt-dlp not found. Install with: brew install yt-dlp" >&2
  exit 127
fi

# Match the common "bestvideo+bestaudio" behavior.
# Keep --restrict-filenames to avoid spaces/special chars in output paths.
yt-dlp \
  --no-playlist \
  --restrict-filenames \
  -f "bestvideo+bestaudio/best" \
  -o "${out_dir}/%(title)s.%(ext)s" \
  "${url}"

echo "Downloaded to: ${out_dir}"
