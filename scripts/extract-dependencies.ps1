$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$repos = @("Application01", "Application02", "Application03", "Application04", "Application05")
$results = @()

foreach ($repo in $repos) {
  Set-Location $repo
  $projectName = $repo
  $nuget = @()
  $dll = @()

  $csproj = Get-ChildItem -Recurse -Filter *.csproj | Select-Object -First 1
  if ($csproj) {
    $projectName = Split-Path $csproj.Directory.FullName -Leaf
  }

  Get-ChildItem -Recurse -Filter *.csproj | ForEach-Object {
    [xml]$xml = Get-Content $_.FullName
    $nuget += $xml.Project.ItemGroup.PackageReference | ForEach-Object { $_.Include }
    $dll += $xml.Project.ItemGroup.COMReference | ForEach-Object { $_.Include }
    $dll += $xml.Project.ItemGroup.Reference |
      Where-Object { $_.Include -match "Application" -or $_.HintPath -match "Application" } |
      ForEach-Object { $_.Include }
  }

  Get-ChildItem -Recurse -Filter packages.config -ErrorAction SilentlyContinue | ForEach-Object {
    [xml]$xml = Get-Content $_.FullName
    $nuget += $xml.packages.package | ForEach-Object { $_.id }
  }

  $results += [PSCustomObject]@{
    project = $projectName
    nuget = $nuget | Sort-Object -Unique
    dll = $dll | Sort-Object -Unique
  }

  Set-Location ..
}

$results | ConvertTo-Json -Depth 5 | Out-File dependencies.json -Encoding utf8
$results | ConvertTo-Json -Depth 5 | Out-File "dependencies_$timestamp.json" -Encoding utf8