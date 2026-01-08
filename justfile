[private]
default:
  @just --list -u

act EVENT="push":
  act {{EVENT}} -e event.json  -W .github/workflows/deploy.yaml

release EVENT="push":
  @act {{EVENT}} -e event.json  -W .github/workflows/release-please.yaml -s GITHUB_TOKEN="$(gh auth token)"

trigger-ci:
  echo "" >> shared/frontend-a/Dockerfile
  echo "" >> terraform/test
  git add --all
  git commit -m "trigger-ci"
  git push

