# OpenRec by Naga Codex

A free, open-source screen recorder and demo builder — built for creators, developers, and AI pipelines.

> **OpenRec** is Naga Codex's build of the open-source [OpenScreen](https://github.com/getopenscreen/openscreen) project, rebranded and maintained for our own tooling and community. MIT licensed.

---

## What it does

Record your screen and turn the result into polished product demos, walkthroughs, or content — ready to post on X, YouTube, a docs page, or a landing page.

- Record a specific window or your whole screen
- Record microphone and system audio
- Webcam overlay with picture-in-picture
- Auto or manual zooms with adjustable depth, duration, and easing
- Automatic captions — transcribed on-device, works offline
- AI editing assistant (bring your own key — Claude, OpenAI, Gemini, Mistral, and more)
- Wallpapers, gradients, or custom backgrounds
- Motion blur, crop, trim, speed control
- Text, arrow, and image annotations
- Export to MP4 or GIF — GPU-accelerated on Apple Silicon

---

## Build it yourself (macOS Apple Silicon)

This repo includes a build script that compiles everything from source and produces a plain `.app` — no DMG, no installer, no code signing required for local use.

**Prerequisites:** macOS 13+, Xcode, Homebrew, Node 22.22.1, Rust, LLVM

```bash
git clone https://github.com/Nagacash/openrec.git
cd openrec
chmod +x build-openrec.sh
./build-openrec.sh
```

The script checks all prerequisites, builds each native component in the right order, and outputs `dist/mac-arm64/OpenRec.app`. Drag it to `/Applications` and you're done.

Full step-by-step instructions: see [BUILD_GUIDE.md](BUILD_GUIDE.md)

---

## Stack

- **Shell:** Electron
- **Frontend:** React + TypeScript + Vite + TailwindCSS
- **Rendering:** PixiJS + Rust compositor (wgpu/Metal on macOS)
- **Screen capture:** ScreenCaptureKit (macOS), WGC (Windows), PipeWire (Linux)
- **Captions:** whisper.cpp (on-device)
- **Video:** FFmpeg (vendored LGPL binaries)

---

## Links

- **Naga Codex:** [nagacodex.cloud](https://nagacodex.cloud)
- **Upstream project:** [github.com/getopenscreen/openscreen](https://github.com/getopenscreen/openscreen)

---

## License

MIT — free for personal and commercial use. Original work by the OpenScreen contributors.
