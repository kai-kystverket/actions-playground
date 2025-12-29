package schema

import (
	git "cue.dev/x/githubactions"
)

#Terraform: #Job & {
	type: "terraform"
	paths: [...string] | *[
		"terraform/*.tf",
		"terraform/*.hcl",
		"terraform/*.tfvars",
	]
	pull_request: git.#Job & {
		name: "preview"
		uses: "./reusable-apply-iac.yaml"
	}
	deploy: git.#Job & {
		name: "deploy"
		uses: "./reusable-apply-iac.yaml"
	}
}
