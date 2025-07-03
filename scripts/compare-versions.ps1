if (Test-Path previous/dependencies.json) {
  $new = Get-Content dependencies.json | ConvertFrom-Json
  $old = Get-Content previous/dependencies.json | ConvertFrom-Json
  $diff = Compare-Object $old $new -IncludeEqual -Property project, nuget, dll
  $diff | Format-List | Out-File artifacts/diff_report.txt
}