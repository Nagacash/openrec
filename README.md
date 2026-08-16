<img width="2752" height="1536" alt="OpenRec UI mockup" src="https://github.com/user-attachments/assets/2af26c62-f5be-4a0c-8d92-657a37737d6c" />
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

**Prerequisites:** macOS 13+, Xcode, Homebrew, Node 22.22.1, Rust, LLVM

```bash
git clone https://github.com/Nagacash/openrec.git
cd openrec
chmod +x build-openrec.sh
./build-openrec.sh
```

Outputs `dist/mac-arm64/OpenRec.app` — drag it to `/Applications`.

Full instructions: [BUILD_GUIDE.md](BUILD_GUIDE.md)

---

## Stack

Electron · React · TypeScript · Vite · Rust (wgpu/Metal) · ScreenCaptureKit · whisper.cpp · FFmpeg

---

## Links

- **Naga Codex:** [nagacodex.cloud](https://nagacodex.cloud)
- **Upstream:** [github.com/getopenscreen/openscreen](https://github.com/getopenscreen/openscreen)

---

MIT License — free for personal and commercial use.
