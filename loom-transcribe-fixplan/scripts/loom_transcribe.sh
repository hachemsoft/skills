#!/usr/bin/env bash
set -euo pipefail

input="${1:-}"
lang="${2:-auto}"
model="${3:-/opt/homebrew/opt/whisper-cpp/share/whisper-cpp/models/ggml-small.bin}"

if [[ -z "${input}" ]]; then
  echo "Usage: loom_transcribe.sh <video_or_audio_path> [lang] [model_path]" >&2
  exit 2
fi

if [[ ! -f "${input}" ]]; then
  echo "Input not found: ${input}" >&2
  exit 2
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg not found. Install with: brew install ffmpeg" >&2
  exit 127
fi

whisper_bin="/opt/homebrew/opt/whisper-cpp/bin/whisper-cli"
if ! command -v whisper-cli >/dev/null 2>&1; then
  if [[ -x "${whisper_bin}" ]]; then
    whisper_cmd="${whisper_bin}"
  else
    echo "whisper-cli not found. Install with: brew install whisper-cpp" >&2
    exit 127
  fi
else
  whisper_cmd="whisper-cli"
fi

if [[ ! -f "${model}" ]]; then
  echo "Model not found: ${model}" >&2
  echo "Download example (small):" >&2
  echo "  mkdir -p \"$(dirname "${model}")\" && curl -L -o \"${model}\" \"https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin\"" >&2
  exit 2
fi

base="${input%.*}"
wav="${base}.wav"

# Convert to whisper-friendly WAV (16kHz mono PCM s16le).
ffmpeg -y -i "${input}" -vn -ac 1 -ar 16000 -c:a pcm_s16le "${wav}" >/dev/null

# Auto-detect language by default (pass e.g. "fr" as 2nd arg to force one); plain text output.
"${whisper_cmd}" -m "${model}" -f "${wav}" -l "${lang}" -otxt

echo "Transcript: ${wav}.txt"
