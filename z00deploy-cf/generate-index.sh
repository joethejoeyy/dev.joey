#!/usr/bin/env bash

# ----------------------------
# Parameters
# ----------------------------
LOCAL_FILE_MODE=false   # set to true for direct JSON links

# Automatically set ROOT to the folder containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR"  # repo root = folder where script lives
VIEWER="json-viewer.html"
INDEX_PATH="$ROOT/index.html"

# ----------------------------
# Configuration
# ----------------------------
SKIP_DIRS=(".git" "bin" "obj" "node_modules")
EXTENSIONS=("html" "htm" "md" "txt" "pdf" "json" "png" "jpg")

CSS='
:root { --bg:#0f1020; --card:#17182b; --ink:#e9e9ff; --muted:#a5a7d4; --rule:#2a2b45; --accent:#7aa2ff; }
*{box-sizing:border-box}
body{margin:0;font:15px/1.5 system-ui,-apple-system,Segoe UI,Roboto,sans-serif;background:var(--bg);color:var(--ink)}
main{max-width:1100px;margin:40px auto;padding:24px;background:var(--card);border-radius:16px;box-shadow:0 8px 40px rgba(0,0,0,.35)}
h1{margin:0 0 8px}
.summary-row{display:flex;justify-content:space-between;align-items:center;gap:12px}
summary{cursor:pointer;list-style:none;outline:none}
summary::-webkit-details-marker{display:none}
.folder{padding:12px 14px;border:1px solid var(--rule);border-radius:12px;margin:10px 0;background:#14152a}
.folder summary{font-weight:600}
.folder small{color:var(--muted)}
.folder ul{margin:10px 0 0 0;padding-left:18px}
.folder li{margin:4px 0}
.folder a{color:var(--ink);text-decoration:none;border-bottom:1px dotted var(--rule)}
.folder a:hover{border-bottom-color:var(--accent)}
.hr{height:1px;background:var(--rule);margin:18px 0}
header .meta{color:var(--muted);font-size:13px}
.search{width:100%;padding:10px 12px;border-radius:10px;border:1px solid var(--rule);background:#131428;color:var(--ink)}
.note{color:var(--muted);font-size:13px;margin-top:6px}
.badge{display:inline-block;padding:2px 8px;border:1px solid var(--rule);border-radius:999px;font-size:12px;margin-left:6px}
'

# ----------------------------
# Helper: Relative path
# ----------------------------
get_rel_path() {
  local full="$1"
  local root="$2"
  python3 -c "import os.path; print(os.path.relpath('$full', '$root'))" 2>/dev/null
}

# ----------------------------
# Collect files
# ----------------------------
echo "Collecting files under $ROOT..."
tmpfile=$(mktemp)

while IFS= read -r file; do
  ext="${file##*.}"
  skip=false

  # skip unwanted extensions
  if [[ ! " ${EXTENSIONS[*]} " =~ " $ext " ]]; then continue; fi

  # skip index.html
  name=$(basename "$file")
  if [[ "$name" =~ ^index\.html?$ ]]; then continue; fi

  # skip noisy dirs
  dir=$(dirname "$file")
  for s in "${SKIP_DIRS[@]}"; do
    if [[ "$dir" =~ "/$s" ]]; then skip=true; break; fi
  done
  $skip && continue

  rel_dir=$(get_rel_path "$dir" "$ROOT")
  [[ "$rel_dir" == "." ]] && rel_dir="/"
  echo "$rel_dir|$file" >> "$tmpfile"
done < <(find "$ROOT" -type f 2>/dev/null | sort)

# ----------------------------
# Build HTML
# ----------------------------
mode_text=$([ "$LOCAL_FILE_MODE" = true ] && echo "LocalFileMode" || echo "Cloud Mode")
viewer_root="/${VIEWER#/}"

{
cat <<HTML
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<base href="/" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>ShareWithFriends — Index</title>
<style>
$CSS
</style>
</head>
<body>
<main>
  <header>
    <h1>📂 ShareWithFriends — Index <span class="badge">$mode_text</span></h1>
    <div class="meta">Generated: $(date '+%Y-%m-%d %H:%M') • Root: $ROOT</div>
    <div class="hr"></div>
    <input class="search" id="filter" placeholder="Type to filter folders & files..." />
    <div class="note">Tip: each section below is collapsible. Click folder name to expand.</div>
  </header>
  <section id="folders">
HTML

sort "$tmpfile" | cut -d'|' -f1 | uniq | while read -r folder; do
  files_in_group=$(grep "^$folder|" "$tmpfile" | cut -d'|' -f2-)
  count=$(echo "$files_in_group" | grep -c .)
  echo "  <details class=\"folder\"><summary><div class=\"summary-row\"><span>📂 $folder</span><small>$count file(s)</small></div></summary>"
  echo "    <ul>"
  while read -r file; do
    [[ -z "$file" ]] && continue
    name=$(basename "$file")
    rel_file=$(get_rel_path "$file" "$ROOT")
    rel_web="${rel_file// /%20}"

    if [[ "$name" == *.json ]]; then
      if [ "$LOCAL_FILE_MODE" = true ]; then
        href="/$rel_web"
      else
        href="$viewer_root?src=$rel_web"
      fi
    else
      href="/$rel_web"
    fi

    printf '      <li><a href="%s">%s</a></li>\n' "$href" "$name"
  done <<< "$files_in_group"
  echo "    </ul>"
  echo "  </details>"
done

cat <<'HTML'
  </section>
</main>
<script>
(function(){
  var input = document.getElementById('filter');
  var sections = Array.prototype.slice.call(document.querySelectorAll('details.folder'));
  function norm(s){ return (s||'').toLowerCase(); }
  input.addEventListener('input', function(){
    var q = norm(input.value.trim());
    sections.forEach(function(d){
      if (!q) { d.style.display = ''; return; }
      var text = norm(d.textContent || '');
      d.style.display = text.indexOf(q) !== -1 ? '' : 'none';
    });
  });
})();
</script>
</body>
</html>
HTML
} > "$INDEX_PATH"

rm -f "$tmpfile"
echo "✅ index.html written to $INDEX_PATH"

# Optional: auto-open in browser (uncomment if desired)
# xdg-open "$INDEX_PATH" >/dev/null 2>&1 &
