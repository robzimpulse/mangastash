#!/usr/bin/env bash
# bump_version.sh — compute and apply the next release version to a pubspec.yaml
#
# Purpose: the manual release pipeline (.github/workflows/release.yaml) calls
# this to bump the root pubspec.yaml version before committing and tagging.
# It supports exactly major / minor / patch bumps of a plain X.Y.Z version
# (no pre-release or +build suffixes) and rewrites only the `version:` line,
# leaving every other line of the pubspec untouched. The next version is
# printed to stdout so callers can build the `v` tag from it.
#
# Usage: bash scripts/bump_version.sh <pubspec_path> <major|minor|patch>
# Exit code: 0 on success (next version on stdout), 1 on any invalid input
# (reason printed to stderr).

set -euo pipefail

die() {
  printf 'bump_version: %s\n' "$1" >&2
  exit 1
}

[ "$#" -eq 2 ] || die "expected 2 arguments: <pubspec_path> <major|minor|patch>"
PUBSPEC="$1"
LEVEL="$2"
[ -f "$PUBSPEC" ] || die "pubspec not found: $PUBSPEC"
case "$LEVEL" in
  major | minor | patch) ;;
  *) die "unknown bump level: $LEVEL (expected major, minor, or patch)" ;;
esac

VERSION="$(grep -E '^version: ' "$PUBSPEC" | head -n 1 | sed 's/^version: //')"
[ -n "$VERSION" ] || die "no 'version:' line found in $PUBSPEC"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] ||
  die "unsupported version '$VERSION' (expected plain major.minor.patch, e.g. 0.2.1)"

IFS='.' read -r MAJOR MINOR PATCH <<<"$VERSION"
NEXT="$MAJOR.$MINOR.$PATCH"
case "$LEVEL" in
  major) NEXT="$((MAJOR + 1)).0.0" ;;
  minor) NEXT="$MAJOR.$((MINOR + 1)).0" ;;
  patch) NEXT="$MAJOR.$MINOR.$((PATCH + 1))" ;;
esac

TMP="$(mktemp)"
awk -v replacement="version: $NEXT" '
  !replaced && /^version: / { print replacement; replaced = 1; next }
  { print }
' "$PUBSPEC" >"$TMP"
mv "$TMP" "$PUBSPEC"

printf '%s\n' "$NEXT"
