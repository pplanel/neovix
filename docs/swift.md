# Swift in neovix

## What comes from where

| Piece | Source | Why |
| --- | --- | --- |
| sourcekit-lsp, swift-format, lldb-dap | System toolchain (Xcode via `xcrun` on macOS) | Must match the compiler that builds the project. nixpkgs ships Swift 5.10; Xcode ships 6.x. |
| swiftformat, swiftlint | Nix | Standalone tools |
| xcodebuild.nvim, xcode-build-server, xcbeautify | Nix (macOS only) | For Xcode projects |

On Linux, install a Swift toolchain (for example with [swiftly](https://www.swift.org/install/)) so that `sourcekit-lsp` and `swift` are on your `PATH`.

## SwiftPM projects

### Create a package

```bash
mkdir Hello && cd Hello
swift package init --type executable   # or: --type library, --type tool
```

Any folder with a `Package.swift` at its root works.

### Open it

```bash
nvim Sources/Hello/Hello.swift
```

On first open, sourcekit-lsp takes a few seconds to index. If the package has never been built, build it once (`<leader>Xb`) so dependencies get resolved.

### Build, run, test

| Keys | Runs |
| --- | --- |
| `<leader>Xb` | `swift build` |
| `<leader>Xr` | `swift run` |
| `<leader>Xt` | `swift test` |
| `<leader>XC` | `swift package clean` |

Each command runs from the package root in a terminal split that stays open.

### Debug

1. Build with `<leader>Xb`. The debugger launches the binary but doesn't build it.
2. Set a breakpoint: `<leader>db`.
3. Start: `<leader>dc`, then pick **Launch SwiftPM executable**.
4. Accept the suggested path, `.build/debug/<ExecutableName>`.

## Formatting and linting

- Files are formatted on save with **SwiftFormat**, which reads the project's `.swiftformat` if there is one.
- A project with a `.swift-format` file is formatted with Apple's **swift-format** instead.
- **SwiftLint** runs on open and on save, and reads `.swiftlint.yml`.

Toggle format-on-save with `<leader>uf` (globally) or `<leader>uF` (current buffer).

## Xcode projects (macOS)

In a folder with an `.xcodeproj` or `.xcworkspace`, the same `<leader>Xb/Xr/Xt` keys go through [xcodebuild.nvim](https://github.com/wojciech-kulik/xcodebuild.nvim).

Run `<leader>Xs` (`:XcodebuildSetup`) once per project. It picks the scheme and device, and runs `xcode-build-server config` so that sourcekit-lsp understands the project.

| Keys | Action |
| --- | --- |
| `<leader>XX` | All actions (picker) |
| `<leader>Xd` / `<leader>XS` | Select device / scheme |
| `<leader>Xn` / `<leader>XT` | Test nearest / test class |
| `<leader>Xf` | Rerun failing tests |
| `<leader>Xe` | Test explorer |
| `<leader>Xl` | Toggle logs |
| `<leader>Xc` / `<leader>XR` | Code coverage / coverage report |
| `<leader>XD` | Build and debug |
| `<leader>XN` | Debug nearest test |
| `<leader>Xo` | Open in Xcode |

`buildServer.json` records a stable symlink, `~/.local/share/nvim/neovix/bin/xcode-build-server`, rather than a Nix store path. Upgrading neovix therefore never breaks existing projects.

Not bundled: `pymobiledevice3` (it's broken in nixpkgs; only needed for physical devices below iOS 17) and `xcp` (keeps the Xcode project in sync when files are added or moved from the file tree).
