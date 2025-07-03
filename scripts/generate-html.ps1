$svg = Get-Content artifacts/graph.svg -Raw
$nodes = (Get-Content artifacts/dependencies.json | ConvertFrom-Json).project
$options = $nodes | Sort-Object | ForEach-Object { "<option value='$_'>$_</option>" } | Out-String
$link = "<p><a href='compare.html'>🔍 Compare Versions</a></p>"

$html = @"
<!DOCTYPE html>
<html>
<head>
  <meta charset='utf-8'>
  <title>Dependency Graph</title>
  <style>
    body { font-family: 'Segoe UI'; background: #f5f5f5; text-align: center; margin: 0; padding: 2rem; }
    header { background: #0366d6; color: white; padding: 1rem; }
    select { font-size: 1rem; margin-top: 1rem; padding: 0.5rem; }
    svg { max-width: 100%; height: auto; background: white; border: 1px solid #ccc; box-shadow: 0 4px 12px rgba(0,0,0,0.1); margin-top: 2rem; }
    footer { margin-top: 2rem; color: #777; font-size: 0.85rem; }
    .dimmed { opacity: 0.2; }
    .highlighted { opacity: 1; }
  </style>
</head>
<body>
  <header>
    <h1>📊 Dependency Graph</h1>
    <label for="nodeSelect">Highlight dependencies for:</label>
    <select id="nodeSelect" onchange="highlightNode(this.value)">
      <option value="">-- Show All --</option>
      $options
    </select>
  </header>
  $svg
  <footer>
    $link<br>
    Generated via GitHub Actions & Graphviz
  </footer>
  <script>
    function highlightNode(selected) {
      const nodes = document.querySelectorAll('g');
      nodes.forEach(el => {
        el.classList.remove('highlighted');
        el.classList.remove('dimmed');
      });

      if (!selected) return; // show all

      nodes.forEach(el => {
        const content = el.textContent;
        const isNode = content.includes('>' + selected + '<');
        const isEdge = content.includes('->') && content.includes(selected);
        const isRelated = content.includes('"' + selected + '"') || content.includes(selected + '"') || content.includes('"' + selected);

        if (isNode || isEdge || isRelated) {
          el.classList.add('highlighted');
        } else {
          el.classList.add('dimmed');
        }
      });
    }
  </script>
</body>
</html>
"@

$html | Out-File artifacts/index.html -Encoding utf8