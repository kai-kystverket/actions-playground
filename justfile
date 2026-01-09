[private]
default:
  @just --list -u

act EVENT="push":
  act {{EVENT}} -e event.json  -W .github/workflows/deploy.yaml

release EVENT="push":
  @act {{EVENT}} -e event.json  -W .github/workflows/release-please.yaml -s GITHUB_TOKEN="$(gh auth token)"

trigger-ci:
  echo "" >> shared/frontend-a/Dockerfile
  echo "" >> terraform/test.tf
  git add --all
  git commit -m "trigger-ci"
  git push

[working-directory: "cue-actions"]
render:
  cue cmd render

[working-directory: "cue-actions"]
dump NAME EXPRESSION: 
  cue eval -e {{EXPRESSION}} --out yaml > _rendered/{{NAME}}.yaml

[working-directory: "cue-actions/_rendered/my-repo"]
run:
  # @just render
  act -W manual_deploy.yaml --input env=dev --input workflow=terraform

