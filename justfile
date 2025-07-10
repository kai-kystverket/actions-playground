[private]
default:
  @just --list -u

act EVENT="push":
  act {{EVENT}} -e event.json  -W .github/workflows/deploy.yaml

