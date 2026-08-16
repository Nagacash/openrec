// swift-tools-version: 5.9

import PackageDescription

let package = Package(
	name: "OpenRecScreenCaptureKitHelper",
	platforms: [
		.macOS(.v13)
	],
	products: [
		.executable(
			name: "openrec-screencapturekit-helper",
			targets: ["OpenRecScreenCaptureKitHelper"]
		),
		.executable(
			name: "openrec-macos-cursor-helper",
			targets: ["OpenRecMacOSCursorHelper"]
		)
	],
	targets: [
		.executableTarget(
			name: "OpenRecScreenCaptureKitHelper",
			path: "Sources/OpenRecScreenCaptureKitHelper"
		),
		.executableTarget(
			name: "OpenRecMacOSCursorHelper",
			path: "Sources/OpenRecMacOSCursorHelper"
		)
	]
)
