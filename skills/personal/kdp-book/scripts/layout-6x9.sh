#!/bin/bash
# Lay out one or more Markdown files as a 6x9in paperback PDF with headless Chrome and report the page count.
# Usage: layout-6x9.sh <out.pdf> <chapter.md> [more.md ...]
# Needs: node (npx marked), Google Chrome. No LaTeX, no pandoc.
set -euo pipefail
OUT="$1"; shift
BODYPT="${BODYPT:-11pt}"   # override: BODYPT=12pt layout-6x9.sh ...
DIR="$(mktemp -d)"
HTML="$DIR/book.html"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
cat > "$HTML" <<'EOF'
<!doctype html><html><head><meta charset="utf-8"><title>Layout sample</title>
<style>
@page { size: 6in 9in; margin: 0.75in 0.6in 0.75in 0.75in; }
html { font-size: BODYPT; }
body { font-family: Georgia, "Times New Roman", serif; line-height: 1.45; color: #111; margin: 0; }
h1 { font-size: 20pt; line-height: 1.2; margin: 0 0 18pt; page-break-before: always; }
h1:first-of-type { page-break-before: auto; }
h2 { font-size: 14pt; margin: 18pt 0 6pt; page-break-after: avoid; }
h3 { font-size: 11.5pt; margin: 14pt 0 4pt; page-break-after: avoid; }
h4 { font-size: 10.5pt; margin: 12pt 0 4pt; page-break-after: avoid; }
p { margin: 0 0 8pt; text-align: left; orphans: 2; widows: 2; }
ul, ol { margin: 0 0 8pt 1.2em; padding: 0; }
li { margin-bottom: 3pt; }
blockquote { border-left: 2pt solid #999; margin: 8pt 0; padding: 4pt 10pt; background: #f4f4f4; page-break-inside: avoid; }
table { border-collapse: collapse; width: 100%; font-size: 9.5pt; margin: 6pt 0 10pt; }
tr, thead { page-break-inside: avoid; } thead { display: table-header-group; }
h4, p > strong:only-child { page-break-after: avoid; }
th, td { border: 0.5pt solid #888; padding: 3pt 5pt; vertical-align: top; text-align: left; }
th { background: #eee; }
code { font-family: Menlo, monospace; font-size: 9.5pt; }
.footnotes, .endnotes { font-size: 8.5pt; line-height: 1.3; }
.endnotes ol { margin-left: 1.4em; } .endnotes a { word-break: break-all; color: #333; text-decoration: none; }
sup { font-size: 70%; line-height: 0; }
hr { border: 0; border-top: 0.5pt solid #999; margin: 12pt 0; }
</style></head><body>
EOF
sed -i '' "s/BODYPT/$BODYPT/" "$HTML"
for f in "$@"; do
  # Footnotes: [^n] markers -> superscripts; "[^n]: text" definitions -> a numbered endnote list.
  python3 -I - "$f" <<'PYF' | npx -y marked --gfm >> "$HTML"
import re,sys
md=open(sys.argv[1],encoding='utf-8').read()
defs=[]
def grab(m):
    defs.append((m.group(1),m.group(2).strip())); return ''
md=re.sub(r'^\[\^(\d+)\]:\s*(.+)$',grab,md,flags=re.M)
md=re.sub(r'\[\^(\d+)\]',r'<sup>\1</sup>',md)
if defs:
    md+='\n\n<div class="endnotes">\n\n'+'\n'.join(f'{n}. {t}' for n,t in defs)+'\n\n</div>\n'
print(md)
PYF
done
echo "</body></html>" >> "$HTML"
"$CHROME" --headless=new --disable-gpu --no-pdf-header-footer --print-to-pdf="$OUT" "file://$HTML" >/dev/null 2>&1
PAGES=$(python3 -I -c "import re,sys; d=open(sys.argv[1],'rb').read(); print(len(re.findall(rb'/Type\s*/Page[^s]', d)))" "$OUT")
WORDS=$(cat "$@" | wc -w | tr -d ' ')
echo "pdf: $OUT"
echo "pages: $PAGES | words: $WORDS | words/page: $(( WORDS / (PAGES>0?PAGES:1) ))"
rm -rf "$DIR"
