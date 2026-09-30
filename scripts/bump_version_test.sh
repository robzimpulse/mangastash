# bump_version_test.sh — regression tests for scripts/bump_version.sh
#
# Purpose: verifies the version-bump computation and pubspec rewriting used by
# the manual release pipeline (.github/workflows/release.yaml) before a tag is
# pushed. Covers semver arithmetic (major/minor/patch), in-place pubspec
# rewriting, and rejection of malformed inputs.
#
# Usage: bash scripts/bump_version_test.sh
# Exit code 0 = all tests pass, 1 = at least one failure (details printed).

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUBJECT="$SCRIPT_DIR/bump_version.sh"

PASS=0
FAIL=0

make_fixture() {
  FIXTURE="$(mktemp -t pubspec.XXXXXX)"
  printf 'name: mangastash\ndescription: Manga Reader Apps\nversion: %s\n\nenvironment:\n  sdk: ">=3.7.2 <4.0.0"\n' "$1" >"$FIXTURE"
}

# assert_output <level> <old_version> <expected_new_version>
assert_output() {
  local level="$1" old="$2" expected="$3" actual rc
  make_fixture "$old"
  actual="$(bash "$SUBJECT" "$FIXTURE" "$level" 2>/dev/null)"
  rc=$?
  if [ $rc -eq 0 ] && [ "$actual" = "$expected" ]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    printf 'FAIL bump %s of %s: expected %s, got %s (rc=%d)\n' "$level" "$old" "$expected" "$actual" "$rc"
  fi
  rm -f "$FIXTURE"
}

# assert_rewritten <level> <old_version> <expected_new_version> — pubspec must
# end up with exactly the new version on its version: line and nothing else lost.
assert_rewritten() {
  local level="$1" old="$2" expected="$3" new_version line_count
  make_fixture "$old"
  bash "$SUBJECT" "$FIXTURE" "$level" >/dev/null || true
  new_version="$(grep -E '^version: ' "$FIXTURE" | sed 's/^version: //')"
  line_count="$(wc -l <"$FIXTURE" | tr -d ' ')"
  if [ "$new_version" = "$expected" ] && grep -q '^name: mangastash$' "$FIXTURE" && [ "$line_count" -eq 6 ]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    printf 'FAIL rewrite %s: version line is %q (expected %s), file has %s lines\n' "$level" "$new_version" "$expected" "$line_count"
  fi
  rm -f "$FIXTURE"
}

# assert_rejected <level> <version> — bad input must exit non-zero with a message.
assert_rejected() {
  local level="$1" old="$2" stderr rc
  make_fixture "$old"
  stderr="$(bash "$SUBJECT" "$FIXTURE" "$level" 2>&1 >/dev/null)"
  rc=$?
  if [ $rc -ne 0 ] && [ -n "$stderr" ]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    printf 'FAIL reject %s with version %s: rc=%d, stderr=%q\n' "$level" "$old" "$rc" "$stderr"
  fi
  rm -f "$FIXTURE"
}

assert_output patch 0.2.1 0.2.2
assert_output minor 0.2.1 0.3.0
assert_output major 0.2.1 1.0.0
assert_output patch 1.0.0 1.0.1
assert_output major 9.9.9 10.0.0

assert_rewritten patch 0.2.1 0.2.2
assert_rewritten major 0.2.9 1.0.0

assert_rejected pre 0.2.1
assert_rejected patch 0.2.1+5
assert_rejected patch 0.2
assert_rejected patch 0.2.x

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
