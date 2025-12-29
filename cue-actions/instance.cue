package actions

import (
	git "cue.dev/x/githubactions"
	schema "actions.cue/schema"
)

actions: "my-repo": schema.#SuperDeploy & {
	config: jobs: {
		tftest: schema.#Terraform & {
			name: "terraform"
			paths: [
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
		frontend: schema.#Docker & {
			name: "frontend"
			paths: [
				"frontend/**",
			]
			deploy: {
				"resource-group-name": "test"
			}
			// 	pull_request: git.#Job & {
			// 		name:   "build"
			// 		"uses": "./reusable-test.yaml"
			// 	}
		}
	}
}
