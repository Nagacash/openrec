{
  lib,
  buildNpmPackage,
  nodejs_22,
  electron,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
}:

buildNpmPackage {
  nodejs = nodejs_22;
  pname = "openrec";
  # Read, not restated. A hand-copied version is one more thing to remember at
  # release time and it had already drifted two minors behind the app it names.
  # (`npmDepsHash` below still has to be updated by hand — that is Nix, not a
  # choice — but it fails loudly, where a stale version number never does.)
  version = (lib.importJSON ../package.json).version;

  src =
    let
      fs = lib.fileset;
      # gitTracked fails when source is already a store path (path: flake inputs).
      # Detect this and fall back to cleanSource which handles both cases.
      isStorePath = builtins.storeDir == builtins.substring 0 (builtins.stringLength builtins.storeDir) (toString ../.);
      baseFiles = if isStorePath then fs.fromSource (lib.cleanSource ../.) else fs.gitTracked ../.;
    in
    fs.toSource {
      root = ../.;
      fileset = fs.difference baseFiles (
        fs.unions [
          ../nix
          ../flake.nix
          ../flake.lock
          (fs.fileFilter (file: file.hasExt "md") ../.)
        ]
      );
    };

  npmDepsHash = "sha256-1fer91zZlZxC5SoIj3F/bNcLoD+Q+QxLpCZF067Upko=";

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  # electron-builder is not needed — we wrap system electron directly
  npmFlags = [ "--ignore-scripts" ];
  makeCacheWritable = true;

  # vite-plugin-electron compiles electron/ sources into dist-electron/
  # tsconfig has noEmit — tsc is type-check only
  buildPhase = ''
    runHook preBuild
    npx vite build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/openrec"

    # Renderer build output (index.html, JS chunks, copied public/ assets)
    cp -r dist "$out/lib/openrec/"

    # Main process + preload (compiled by vite-plugin-electron)
    cp -r dist-electron "$out/lib/openrec/"

    # Package manifest (electron reads "main" field to find entry point)
    cp package.json "$out/lib/openrec/"

    # Strip devDependencies (electron, vitest, biome, playwright, etc.)
    npm prune --omit=dev --no-save
    cp -r node_modules "$out/lib/openrec/"

    # Asset resolution: when app.isPackaged is false, the main process resolves
    # assets at <appPath>/public/. Place wallpapers at that root to match the
    # packaged layout (electron-builder extraResources -> resources/wallpapers).
    mkdir -p "$out/lib/openrec/public"
    cp -r public/wallpapers "$out/lib/openrec/public/wallpapers"

    # Wrap system electron with the app directory
    mkdir -p "$out/bin"
    makeWrapper "${electron}/bin/electron" "$out/bin/openrec" \
      --add-flags "$out/lib/openrec" \
      --set ELECTRON_IS_DEV 0

    # Install icons to hicolor theme
    for size in 16 24 32 48 64 128 256 512 1024; do
      icon="icons/icons/png/''${size}x''${size}.png"
      if [ -f "$icon" ]; then
        install -Dm644 "$icon" \
          "$out/share/icons/hicolor/''${size}x''${size}/apps/openrec.png"
      fi
    done

    runHook postInstall
  '';

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "openrec";
      desktopName = "OpenRec";
      genericName = "Screen Recorder";
      exec = "openrec %U";
      icon = "openrec";
      comment = "Desktop screen recorder with built-in editor";
      categories = [
        "AudioVideo"
        "Video"
        "Recorder"
      ];
      startupWMClass = "Openrec";
      terminal = false;
    })
  ];

  meta = {
    description = "Desktop screen recorder with built-in editor";
    homepage = "https://github.com/EtienneLescot/openrec";
    license = lib.licenses.mit;
    mainProgram = "openrec";
    platforms = lib.platforms.linux;
  };
}
