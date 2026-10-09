#!/bin/bash
# Lay out one or more Markdown files as a 6x9in paperback PDF with headless Chrome and report the page count.
# Usage: layout-6x9.sh <out.pdf> <chapter.md> [more.md ...]
# Needs: node (npx marked), Google Chrome. No LaTeX, no pandoc.
set -euo pipefail
OUT="$1"; shift
DIR="$(mktemp -d)"
HTML="$DIR/book.html"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
cat > "$HTML" <<'EOF'
<!doctype html><html><head><meta charset="utf-8"><title>Layout sample</title>
<style>
@page { size: 6in 9in; margin: 0.75in 0.6in 0.75in 0.75in; }
html { font-size: 11pt; }
body { font-family: Georgia, "Times New Roman", serif; line-height: 1.45; color: #111; margin: 0; }
h1 { font-size: 20pt; line-height: 1.2; margin: 0 0 18pt; page-break-before: always; }
h1:first-of-type { page-break-before: auto; }
h2 { font-size: 14pt; margin: 18pt 0 6pt; page-break-after: avoid; }
h3 { font-size: 11.5pt; margin: 14pt 0 4pt; page-break-after: avoid; }
p { margin: 0 0 8pt; text-align: left; orphans: 2; widows: 2; }
ul, ol { margin: 0 0 8pt 1.2em; padding: 0; }
li { margin-bottom: 3pt; }
blockquote { border-left: 2pt solid #999; margin: 8pt 0; padding: 4pt 10pt; background: #f4f4f4; page-break-inside: avoid; }
table { border-collapse: collapse; width: 100%; font-size: 9.5pt; margin: 6pt 0 10pt; page-break-inside: avoid; }
th, td { border: 0.5pt solid #888; padding: 3pt 5pt; vertical-align: top; text-align: left; }
th { background: #eee; }
code { font-family: Menlo, monospace; font-size: 9.5pt; }
.footnotes { font-size: 9pt; }
hr { border: 0; border-top: 0.5pt solid #999; margin: 12pt 0; }
</style></head><body>
EOF
for f in "$@"; do
  npx -y marked --gfm < "$f" >> "$HTML"
done
echo "</body></html>" >> "$HTML"
"$CHROME" --headless=new --disable-gpu --no-pdf-header-footer --print-to-pdf="$OUT" "file://$HTML" >/dev/null 2>&1
PAGES=$(python3 -I -c "import re,sys; d=open(sys.argv[1],'rb').read(); print(len(re.findall(rb'/Type\s*/Page[^s]', d)))" "$OUT")
WORDS=$(cat "$@" | wc -w | tr -d ' ')
echo "pdf: $OUT"
echo "pages: $PAGES | words: $WORDS | words/page: $(( WORDS / (PAGES>0?PAGES:1) ))"
rm -rf "$DIR"
