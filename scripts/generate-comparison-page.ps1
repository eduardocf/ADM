# List all timestamped dependency files
$files = Get-ChildItem -Path . -Filter "dependencies*.json" | Sort-Object -Descending -Property LastWriteTime
if ($files.Count -lt 2) {
  "Not enough versioned files to compare." | Out-File artifacts/compare.html
  return
}

$latest = $files[0].Name
$previous = $files[1].Name

$latestJson = Get-Content $latest | ConvertFrom-Json
$previousJson = Get-Content $previous | ConvertFrom-Json

$report = @"
<!DOCTYPE html>
<html>
<head>
  <meta charset='utf-8'>
  <title>Application Dependency Mapping Comparison</title>
  <style>
    body { font-family: 'Segoe UI'; background: #fafafa; padding: 2rem; }
    h2 { color: #0366d6; }
    .diff { border: 1px solid #ccc; padding: 1rem; background: #fff; margin-bottom: 2rem; }
    .added { color: green; }
    .removed { color: red; }
  </style>
</head>
<body>
  <h1>🔁 Application Dependency Mapping Comparison</h1>
  <p>Comparing <b>$previous</b> ➡ <b>$latest</b></p>
"@

foreach ($app in $latestJson.project) {
  $prev = $previousJson | Where-Object { $_.project -eq $app }
  $curr = $latestJson | Where-Object { $_.project -eq $app }

  if ($curr -and $prev) {
    $addPkg = ($curr.nuget + $curr.dll) | Where-Object { ($_ -notin ($prev.nuget + $prev.dll)) }
    $remPkg = ($prev.nuget + $prev.dll) | Where-Object { ($_ -notin ($curr.nuget + $curr.dll)) }

    if ($addPkg.Count -eq 0 -and $remPkg.Count -eq 0) { continue }

    $report += "<div class='diff'><h2>$app</h2>"
    if ($addPkg.Count -gt 0) {
      $report += "<p><b>Added:</b> <span class='added'>" + ($addPkg -join ", ") + "</span></p>"
    }
    if ($remPkg.Count -gt 0) {
      $report += "<p><b>Removed:</b> <span class='removed'>" + ($remPkg -join ", ") + "</span></p>"
    }
    $report += "</div>"
  }
}

$report += "</body></html>"
$report | Out-File artifacts/compare.html -Encoding utf8