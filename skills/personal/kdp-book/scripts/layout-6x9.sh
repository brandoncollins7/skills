#!/bin/bash
# Lay out one or more Markdown files as a 6x9in paperback PDF with headless Chrome and report the page count.
# Markers: <!-- layout: worksheet --> (tall rows, new page) and <!-- layout: wide-table --> (8pt, hyphenated) before a table.
# Usage: layout-6x9.sh <out.pdf> <chapter.md> [more.md ...]
# Needs: node (npx marked), Google Chrome. No LaTeX, no pandoc.
set -euo pipefail
OUT="$1"; shift
BODYPT="${BODYPT:-11pt}"   # override: BODYPT=12pt layout-6x9.sh ...
DIR="$(mktemp -d)"
HTML="$DIR/book.html"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
cat > "$HTML" <<'EOF'
<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Layout sample</title>
<style>
@page { size: 6in 9in; margin: 0.75in 0.6in 0.75in 0.75in; @bottom-center { content: counter(page); font: 9pt Georgia, serif; color: #444; } }
* { box-sizing: border-box; max-width: 100%; overflow-wrap: anywhere; }
html { font-size: BODYPT; }
html, body { width: 4.65in; }
body { font-family: Georgia, "Times New Roman", serif; line-height: 1.45; color: #111; margin: 0; }
h1 { font-size: 20pt; line-height: 1.2; margin: 0 0 18pt; page-break-before: always; }
h1:first-of-type { page-break-before: auto; }
h2 { font-size: 14pt; margin: 18pt 0 6pt; page-break-after: avoid; }
h3 { font-size: 11.5pt; margin: 14pt 0 4pt; page-break-after: avoid; }
h4 { font-size: 10.5pt; margin: 12pt 0 4pt; page-break-after: avoid; }
p { margin: 0 0 8pt; text-align: left; orphans: 2; widows: 2; }
ul { margin: 0 0 8pt 1.2em; padding: 0; } ol { margin: 0 0 8pt 1.9em; padding: 0; }
li { margin-bottom: 3pt; }
blockquote { border-left: 2pt solid #999; margin: 8pt 0; padding: 4pt 10pt; background: #f4f4f4; page-break-inside: avoid; }
table { border-collapse: collapse; width: 100%; table-layout: fixed; font-size: 0.864em; margin: 6pt 0 10pt; } /* 9.5pt at 11pt body; scales with BODYPT */
.worksheet td { height: 0.32in; } .worksheet { page-break-before: always; } .worksheet h2, .worksheet h3, .worksheet h4, .worksheet p { page-break-after: avoid; }
.wide table { font-size: 0.682em; table-layout: auto; } .wide th, .wide td { padding: 2pt 3pt; hyphens: auto; overflow-wrap: anywhere; } .wide tr { page-break-inside: avoid; } .wide th:first-child, .wide td:first-child { min-width: 0.8in; } /* 7.5pt at 11pt body; "anywhere" keeps min-content inside the page so Chrome never shrinks the whole document */
tr, thead { page-break-inside: avoid; } thead { display: table-header-group; }
h4, p > strong:only-child, h2 + p, h3 + p { page-break-after: avoid; }
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
md=re.sub(r'(?:\[\^\d+\])+',lambda m:'<sup>'+','.join(re.findall(r'\d+',m.group(0)))+'</sup>',md)  # adjacent notes print as 16,28 not 1628
# A worksheet starts a new page; the heading and the one intro paragraph right before it move with it.
md=re.sub(r'((?:^#{2,4}[^\n]*\n[ \t]*\n)?(?:^(?![ \t]*(?:\||#|<!--))[^\n]+\n[ \t]*\n)?)<!--\s*layout:\s*worksheet\s*-->[ \t]*\n(?:[ \t]*\n)*((?:\|[^\n]*\n?)+)',lambda m:'<div class="worksheet">\n\n'+m.group(1)+m.group(2)+'\n</div>\n',md,flags=re.M)
md=re.sub(r'<!--\s*layout:\s*wide-table\s*-->\s*\n(\|[^\n]*\n(?:\|[^\n]*\n?)+)',lambda m:'<div class="wide">\n\n'+m.group(1)+'\n</div>\n',md)
if defs:
    md+='\n\n<div class="endnotes">\n\n'+'\n'.join(f'{n}. {t}' for n,t in defs)+'\n\n</div>\n'
print(md)
PYF
done
echo "</body></html>" >> "$HTML"
"$CHROME" --headless=new --disable-gpu --no-pdf-header-footer --print-to-pdf="$OUT" "file://$HTML" >/dev/null 2>&1
PAGES=$(python3 -I -c "import re,sys; d=open(sys.argv[1],'rb').read(); print(len(re.findall(rb'/Type\s*/Page[^s]', d)))" "$OUT")
WORDS=$(cat "$@" | wc -w | tr -d ' ')
SCALE=$(python3 -I -c "import sys,collections
try: import pymupdf
except ImportError: print('n/a (pip install pymupdf)'); sys.exit()
d=pymupdf.open(sys.argv[1]); c=collections.Counter()
for p in d:
    for b in p.get_text('dict')['blocks']:
        for l in b.get('lines',[]):
            for sp in l['spans']: c[round(sp['size'],2)]+=len(sp['text'])
tot=sum(c.values()); body=float(sys.argv[2]); common=[k for k,v in c.items() if v>=0.02*tot]
print(round(min(common,key=lambda k:abs(k-body))/body,3) if common else 'n/a')" "$OUT" "${BODYPT%pt}")
echo "print scale: $SCALE (common text size nearest BODYPT / BODYPT; 1.0 = true size; below 0.99 means something overflowed the page width and Chrome shrank the whole document)"
echo "pdf: $OUT"
echo "pages: $PAGES | words: $WORDS | words/page: $(( WORDS / (PAGES>0?PAGES:1) ))"
rm -rf "$DIR"
