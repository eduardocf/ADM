if (-not (Test-Path dependencies.json)) {
  Write-Error "Missing dependencies.json at root."
  exit 1
}

$json = Get-Content dependencies.json | ConvertFrom-Json
$dot = @(
  'digraph Dependencies {',
  '  node[shape=ellipse style="rounded,filled" color="lightgoldenrodyellow" ]'
)
$declared = @{}

foreach ($item in $json) {
  $app = $item.project
  $declared[$app] = $true

  foreach ($pkg in $item.nuget) {
    $dot += '  "' + $app + '" -> "' + $pkg + '" [color=black];'
    $dot += '  "' + $pkg + '" [shape=box, color="#e6f0ff"];'
    $declared[$pkg] = $true
  }

  foreach ($dll in $item.dll) {
    $dot += '  "' + $app + '" -> "' + $dll + '" [color=blue];'
    $dot += '  "' + $dll + '" [shape=ellipse, color="lightgoldenrodyellow"];'
    $declared[$dll] = $true
  }
}

foreach ($node in $declared.Keys | Sort-Object) {
  if (-not ($dot -join "`n" -match '"' + [regex]::Escape($node) + '"')) {
    $dot += '  "' + $node + '";'
  }
}

$dot += '}'
New-Item -ItemType Directory -Force -Path artifacts | Out-Null
$dot | Out-File artifacts/dependency_graph.dot -Encoding utf8
Move-Item dependencies.json artifacts/