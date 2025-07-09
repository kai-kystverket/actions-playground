[private]
default:
  @just --list -u

act:
  act -W .github/workflows/deploy.yaml
