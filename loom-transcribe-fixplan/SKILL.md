---
name: loom-transcribe-fixplan
description: Download Loom videos with yt-dlp, transcribe audio locally with whisper.cpp (whisper-cli), then summarize the need and propose a concrete fix/dev plan. Use when the user shares a Loom URL, asks to transcribe a Loom, or wants to turn a Loom bug report into implementation steps.
---

# Loom -> Transcription -> Plan de fix/dev

## Quick start

This workflow turns a Loom into: (1) transcript, (2) concise understanding, (3) actionable fix plan.

### Inputs accepted
- Loom share URL (preferred)
- MP4 path or uploaded file (fallback)
- Existing transcript text (fallback)

## Workflow

Work in `/tmp/loom/` to keep artifacts out of the repo.

### 1) Download the Loom (yt-dlp)

Run the bundled script (path relative to this skill's directory):

```bash
bash scripts/loom_download.sh "<LOOM_URL>" "/tmp/loom"
```

If the URL is not accessible (private / auth required), stop and ask for either:
- exported MP4 upload, or
- Loom transcript copy-paste.

### 2) Extract audio (ffmpeg) and transcribe (whisper-cli)

Transcribe via whisper.cpp locally:

```bash
bash scripts/loom_transcribe.sh "/tmp/loom/<video>.mp4"          # auto-detects the language
# bash scripts/loom_transcribe.sh "/tmp/loom/<video>.mp4" fr     # …or force one
```

Outputs:
- WAV: 16kHz mono PCM
- Transcript: `*.wav.txt`

Dependencies (all via Homebrew): `yt-dlp`, `ffmpeg`, `whisper-cpp` (model `ggml-small.bin` expected at `/opt/homebrew/opt/whisper-cpp/share/whisper-cpp/models/`).

### 3) Produce the deliverables

Using the transcript, produce:

#### A) Understanding
- 5-10 bullet points: what happened, where, and the user pain
- Explicit "current behavior" vs "expected behavior"
- Repro steps (from transcript)

#### B) Fix/dev plan (concrete)
- Identify likely frontend + backend touchpoints in the relevant repo(s) of the current project
- Propose UX fix (explicit confirmation, affordances)
- Propose backend guard/idempotency if duplicates are possible
- Include test plan: manual steps + any relevant automated tests

## Quality checks
- If the transcript is noisy: rewrite it cleanly (in the recording's language) before planning.
- Avoid guessing product semantics: keep statements grounded in transcript evidence.
- For duplicate events: always check both "UI triggers multiple writes" and "backend writes on side-effects".

## Example

User: "Voici une Loom, peux-tu retranscrire et proposer un fix ?"

Assistant:
1. Download Loom via `loom_download.sh`
2. Transcribe via `loom_transcribe.sh`
3. Provide summary + implementation plan + test plan
