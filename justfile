[private]
default:
  @just --list -u

act EVENT="push":
  act {{EVENT}} -e event.json  -W .github/workflows/deploy.yaml

release EVENT="push":
  @act {{EVENT}} -e event.json  -W .github/workflows/release-please.yaml -s GITHUB_TOKEN="$(gh auth token)"

