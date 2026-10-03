#!/bin/sh
# Builds and runs every unit test, then builds the CLI and checks its behaviour
# against the example site and the edge-case fixtures.
#
#   sh tests/smoke.sh            (uses `salam` from PATH, or set SALAM=/path/to/salam)
set -u
cd "$(dirname "$0")/.." || exit 1
SALAM=${SALAM:-salam}
failures=0

pass() { echo "PASS  $1"; }
fail() { echo "FAIL  $1"; failures=$((failures + 1)); }

compile() { # compile <source> <output>
    "$SALAM" build "$1" --output="$2" --log-level=error >build/compile.log 2>&1
    status=$?
    if [ $status -ne 0 ]; then
        cat build/compile.log
    fi
    return $status
}

has() { grep -qF -- "$2" "$1"; }

rm -rf build tmp-site
mkdir -p build

echo "== unit tests"
for src in tests/unit_*.salam; do
    name=$(basename "$src" .salam)
    if compile "$src" "build/$name"; then
        if "./build/$name" >"build/$name.out" 2>&1; then
            pass "$name ($(grep -c '^PASS' "build/$name.out") checks)"
        else
            fail "$name"
            cat "build/$name.out"
        fi
    else
        fail "$name does not compile"
    fi
done

echo "== cli"
if ! compile src/main.salam build/salam-press; then
    fail "salam-press does not compile"
    exit 1
fi
BIN=./build/salam-press

if [ "$($BIN version)" = "salam-press 0.1.0" ]; then pass "version"; else fail "version"; fi
$BIN help | grep -q "Usage:" && pass "help" || fail "help"

$BIN --bogus >/dev/null 2>&1; [ $? -eq 2 ] && pass "unknown option exits 2" || fail "unknown option exits 2"
$BIN --out >/dev/null 2>&1; [ $? -eq 2 ] && pass "missing value exits 2" || fail "missing value exits 2"
$BIN --src=does-not-exist --out=tmp-site >/dev/null 2>&1; [ $? -eq 1 ] && pass "missing source exits 1" || fail "missing source exits 1"
$BIN --templates=nowhere --out=tmp-site >/dev/null 2>&1; [ $? -eq 1 ] && pass "missing templates exits 1" || fail "missing templates exits 1"

echo "== example site"
out=$($BIN --out=tmp-site --title="Smoke Site")
[ "$out" = "Built 3 pages (1 draft skipped) -> tmp-site" ] && pass "report line" || { fail "report line: $out"; }
for f in index.html welcome.html markdown-guide.html about.html style.css; do
    [ -f "tmp-site/$f" ] && pass "wrote $f" || fail "missing $f"
done
[ ! -f tmp-site/draft-ideas.html ] && pass "draft skipped" || fail "draft was published"
has tmp-site/welcome.html '<h2 id="what-you-get">What you get</h2>' && pass "heading ids" || fail "heading ids"
has tmp-site/welcome.html '<nav class="toc">' && pass "toc present" || fail "toc present"
has tmp-site/welcome.html '<strong>Markdown</strong>' && pass "bold" || fail "bold"
has tmp-site/welcome.html '<a href="markdown-guide.html">Markdown guide</a>' && pass "relative link" || fail "relative link"
has tmp-site/markdown-guide.html '<pre><code class="language-salam">' && pass "code fence language" || fail "code fence language"
has tmp-site/markdown-guide.html '&lt;div&gt;' && pass "code spans escaped" || fail "code spans escaped"
[ "$(grep -c '<h1' tmp-site/welcome.html)" = "1" ] && pass "single h1" || fail "single h1"
has tmp-site/index.html '<title>Smoke Site</title>' && pass "site title" || fail "site title"
first=$(grep -n 'welcome.html">Welcome' tmp-site/index.html | head -1 | cut -d: -f1)
second=$(grep -n 'markdown-guide.html">Markdown' tmp-site/index.html | head -1 | cut -d: -f1)
[ -n "$first" ] && [ -n "$second" ] && [ "$first" -lt "$second" ] && pass "index sorted newest first" || fail "index sorted newest first"
has tmp-site/index.html 'about.html">About' && pass "nav links" || fail "nav links"

echo "== fixtures"
rm -rf tmp-site
out=$($BIN --src=tests/fixtures/content --out=tmp-site)
[ "$out" = "Built 3 pages (1 draft skipped) -> tmp-site" ] && pass "fixture report" || fail "fixture report: $out"
has tmp-site/plain-notes.html '<title>plain-notes · Salam Press Site</title>' && pass "title falls back to file name" || fail "title falls back to file name"
has tmp-site/plain-notes.html '&lt;script&gt;alert(1)&lt;/script&gt;' && pass "script tag escaped" || fail "script tag escaped"
has tmp-site/plain-notes.html '<li>two</li>' && pass "star bullets" || fail "star bullets"
has tmp-site/crlf.html '<li>item b</li>' && pass "CRLF input" || fail "CRLF input"
has tmp-site/crlf.html 'Windows Line Endings' && pass "CRLF title" || fail "CRLF title"
has tmp-site/special-chars.html 'Tom &amp; Jerry &lt;3' && pass "title escaped" || fail "title escaped"
has tmp-site/special-chars.html 'Quotes &quot;inside&quot; attributes' && pass "description escaped" || fail "description escaped"
has tmp-site/special-chars.html 'An unclosed *star and an unclosed `tick' && pass "unclosed markers survive" || fail "unclosed markers survive"
[ ! -f tmp-site/hidden.html ] && pass "fixture draft skipped" || fail "fixture draft published"

rm -rf tmp-site
echo
if [ "$failures" -eq 0 ]; then
    echo "All checks passed."
    exit 0
fi
echo "$failures check(s) failed."
exit 1
