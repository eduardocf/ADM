$svg = Get-Content artifacts/graph.svg -Raw
$nodes = (Get-Content artifacts/dependencies.json | ConvertFrom-Json).project
$options = $nodes | Sort-Object | ForEach-Object { "<option value='$_'>$_</option>" } | Out-String

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
    svg { max-width: 100%; background: white; margin-top: 2rem; border: 1px solid #ccc; }
    footer { margin-top: 2rem; color: #777; font-size: 0.85rem; }
  </style>
</head>
<body>
  <header>
    <h1>📊 Dependency Graph</h1>
    <select id="nodeSelect" onchange="highlightNode(this.value)">
      <option value="">-- Select Node --</option>
      $options
    </select>
  </header>
  $svg
  <footer>Generated via GitHub Actions & Graphviz</footer>
  <script>
    function highlightNode(name) {
      document.querySelectorAll("g").forEach(el => {
        el.style.opacity = "0.2";
        if (el.innerHTML.includes(name)) el.style.opacity = "1.0";
      });
    }
  </script>
</body>
</html>
"@
$html | Out-File artifacts/index.html -Encoding utf8