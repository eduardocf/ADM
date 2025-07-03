$repos = @("Application01", "Application02", "Application03", "Application04", "Application05")
foreach ($repo in $repos) {
  git clone https://x-access-token:${env:GH_PAT}@github.com/eduardocf/$repo.git
}