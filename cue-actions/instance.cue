package actions

import (
	git "cue.dev/x/githubactions"
	schema "actions.cue/schema"
)

tf: schema.#Terraform & {
	type: "terraform"
	name: "terraform"
	paths: [
		"terraform/*.tf",
		"terraform/*.hcl",
		"terraform/*.tfvars",
	]
	envs: {
		dev:  _
		test: _
		prod: _
	}
	pull_request: git.#Job & {
		name:      "preview"
		"runs-on": "ubuntu-latest"
	}
	deploy: git.#Job & {
		name:      "deploy"
		"runs-on": "ubuntu-latest"
	}
}

docker: schema.#Docker & {
	name: "frontend"
	paths: [
		"frontend/**",
	]
	deploy: {
		"resource-group-name": "test"
	}
	envs: {
		dev:  _
		test: _
		prod: _
	}
	pull_request: git.#Job & {
		name:      "tests"
		"runs-on": "ubuntu-latest"
	}
}

actions: schema.#SuperDeploy
actions: config: jobs: [tf, docker]
