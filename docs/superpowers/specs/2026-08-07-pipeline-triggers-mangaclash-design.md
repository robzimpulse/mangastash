# Design: Pipeline trigger re-gating, MangaClash removal, macos/windows build fixes

**Date:** 2026-08-07
**Status:** Approved

## Summary

Three changes to the mangastash monorepo:

1. **CI trigger re-gating (Change A):** Build pipelines build only on pull requests; full build + deploy + artifact-attach runs only on version tag pushes. Remove `push: branches: [master]` entirely.
2. **Fix macos + windows CI builds (A1/A2):** Both pipelines currently fail on the GitHub `windows-latest` / `macos-latest` runners due to environment drift and a plugin bug.
3. **Remove MangaClash source (Change B):** The `mangaclash.com` site is taken down; delete the scraper and unregister the source.

Change C (fixing the stale `pubspec_overrides.yaml`) was considered and **dropped** per user direction — `pubspec_overrides.yaml` is left as-is.

## Motivation

### Trigger re-gating
Every merge to `master` currently re-runs all 5 build pipelines (android, web, windows, macos, linux) even though the PR build already verified the merged tree. This wastes CI minutes and re-deploys web to Firebase + GitHub Pages on every merge. The desired contract:

- **PR open/sync** → build, verify, report (comment + Telegram). This is the gate.
- **Tag push `v*.*.*`** → full build + deploy (web → Firebase/Pages, android → Firebase Distribution) + attach artifacts to the GitHub release.
- **Merge to master** → no build runs. The PR already validated it.

Verified against GitHub docs: *"Path filters are not evaluated for pushes of tags."* — so a `paths` filter is **not** needed; removing `push: branches: [master]` is sufficient and tag pushes always fire.

### macos failure (root cause)
`flutter build macos --release` fails at the Swift compile step in the vendored CocoaPod **`flutter_inappwebview_macos` 1.1.2**:

```
error: protocol 'ASWebAuthenticationPresentationContextProviding' requires 'presentationAnchor(for:)' to be available in macOS 10.14 and newer
```

The plugin's `WebAuthenticationSession.swift` declares conformance to `ASWebAuthenticationPresentationContextProviding` (macOS 10.14 requirement) but annotates the required `presentationAnchor(for:)` method `@available(macOS 10.15, *)`. A conforming method must be at least as available as the protocol requirement — the mismatch is a hard error on modern Xcode/SDK builds. `flutter_inappwebview_macos` 1.1.2 is already the latest stable 1.x (only `1.2.0-beta.*` beyond), and `flutter_inappwebview` 6.1.5 is the app's direct dep (`core_network/pubspec.yaml`). So a dependency bump is not the fix.

**Fix:** a post-`pod install` build step that patches the vendored source before `flutter build macos` — insert the `@available(macOS 10.15, *)` annotation (or, if the surrounding context demands it, a `#if` guard) on the `presentationAnchor(for:)` method in the Pod's `WebAuthenticationSession.swift`.

### windows failure (root cause)
`flutter build windows --release` fails at CMake configure:

```
CMake Error at CMakeLists.txt:3 (project):
  Generator
    Visual Studio 16 2019
  could not find any instance of Visual Studio.
```

Flutter 3.32.8's Windows tool selects the CMake generator from the detected Visual Studio version (`visual_studio.dart`: 17 → "Visual Studio 17 2022", anything else → "Visual Studio 16 2019"). The GitHub `windows-latest` runner now ships **VS 2022 only**; VS 2019 was removed. The default generator string ("Visual Studio 16 2019") no longer resolves. This is a time-dependent runner drift — the same workflow built successfully on an earlier `dynamic-source` run.

**Fix:** explicitly pin the CMake generator to **"Visual Studio 17 2022"** for the windows build (e.g. set `CMAKE_GENERATOR` env, or invoke `cmake -G "Visual Studio 17 2022"` ahead of `flutter build windows`), so the build no longer depends on Flutter's default VS-version detection.

### MangaClash removal (motivation)
`mangaclash.com` has been taken down. The scraper is dead weight. Removal scope (confirmed): delete the file + unregister from `Sources.values`. No tests reference MangaClash; no persisted-data references. The html-parser / 3rd-party deps are used by the remaining sources, so they stay.

## Changes

### Change A — CI trigger re-gating (5 files)

For each of `android.yaml`, `web.yaml`, `windows.yaml`, `macos.yaml`, `linux.yaml`:

```yaml
on:
  pull_request:
    types: [opened, reopened, synchronize]
  push:
    tags: ['v*.*.*']          # was: branches: ['master'] + tags
```

- Remove `branches: ['master']` from the `push` event.
- Keep `pull_request` unchanged.
- Keep `push: tags: ['v*.*.*']`.
- **Do not** add a `paths` filter (not needed — verified tags bypass it, and removing the branch trigger is the intent).
- Per-step `if:` conditions stay untouched — `if: github.ref_type == 'tag'` (attach/distribute), `if: ... == 'pull_request'` (comment/Telegram) already match the new trigger surface.

### Change A1 — macos build fix (`macos.yaml`)

Add a step after `Install Flutter` / before `Build Application` that patches the vendored Pod source:

- Locate `macos/Pods/flutter_inappwebview_macos/macos/Classes/WebAuthenticationSession/WebAuthenticationSession.swift`.
- **Root cause (confirmed from vendored source):** the class declares conformance `ASWebAuthenticationPresentationContextProviding` (line 13), but the protocol-required method `presentationAnchor(for:)` is annotated `@available(macOS 10.15, *)` (line 84). Swift requires a conforming method to be at least as available as the protocol requirement — the protocol requires the method from **macOS 10.14**, so the 10.15 annotation breaks the conformance → hard error on modern Xcode/SDK.
- **Fix:** change the method's annotation from `@available(macOS 10.15, *)` to `@available(macOS 10.14, *)` (option 1), matching the protocol requirement. Safe because every call site already gates on `#available(macOS 10.15, *)` inside the class body. Alternative (option 2): guard the whole conformance with `@available(macOS 10.15, *)` — more invasive, not preferred.
- Then run `flutter build macos --release` as today.

Implementation detail confirmed: `pod install` runs inside `flutter build macos` (log shows "Running pod install..." ~286s), so the patch step must run **after** pod install. If the workflow needs a separate `pod install` step before the patch, add one.

### Change A2 — windows build fix (`windows.yaml`)

Force the VS 2022 generator so CMake no longer relies on Flutter's VS-version detection:

- Set the generator before `flutter build windows --release`, e.g.:
  - `$env:CMAKE_GENERATOR = "Visual Studio 17 2022"` (PowerShell), or
  - a `cmake -G "Visual Studio 17 2022"` invocation.
- Keep the existing build, compress, upload, attach, comment, Telegram steps.

### Change B — Remove MangaClash (`domain_manga`)

- **Delete** `module/domain/domain_manga/lib/src/sources/manga_clash_source_external.dart`
- **Edit** `module/domain/domain_manga/lib/src/sources/sources.dart`:
  - Remove `import 'manga_clash_source_external.dart';`
  - Remove `MangaClashSourceExternal(),` from `Sources.values`.
  - Result: `Sources.values = [MangaDexSourceExternal(), AsuraScanSourceExternal()]`.

## Explicitly out of scope
- **Change C** — fixing stale `pubspec_overrides.yaml` (remove `core_runtime`, add `core_auth`): **dropped** per user direction. Left as-is. Note: this means `melos bootstrap` / root `flutter test` remain broken ("No pubspec.yaml found for package core_runtime") — a known pre-existing blocker, not introduced here.

## Verification

1. **CI trigger re-gating:** Confirm each workflow's YAML parses (actionlint or equivalent); confirm no `branches:` remains under `push`; confirm `tags: ['v*.*.*']` preserved.
2. **macos fix:** The PR's own CI run exercises `macos.yaml` on `pull_request`. Confirm the `Build Application` step passes (green).
3. **windows fix:** The PR's own CI run exercises `windows.yaml`. Confirm `Build Application` passes.
4. **MangaClash removal:** `flutter analyze` on `domain_manga` passes with no dangling references; `Sources.values` contains 2 entries; `grep -r mangaclash` (case-insensitive) returns no source hits outside the deleted file.
5. Full `melos run test` for `domain_manga` remains green (or note the pre-existing `core_runtime` bootstrap blocker if it prevents the full run).

## Risks / notes
- The macos + windows fixes are self-verified by the PR's CI run; the first run may need iteration on patch details (macos annotation insertion point, windows generator env).
- Removing `push: branches: [master]` means a merged tree that somehow fails to build is only caught on the next tag push or PR. Accepted trade-off per the requested contract.
- `flutter_inappwebview_macos` 1.1.2 is the latest stable; the patch is vendored-source surgery, not a dependency upgrade.
