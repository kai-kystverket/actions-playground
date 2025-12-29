@experiment(aliasv2)
package actions

import (
	git "cue.dev/x/githubactions"
	schema "actions.cue/schema"
)

actions: "my-repo": schema.#SuperDeploy & {
	config: jobs: {
		terraform~(tl,_): schema.#Terraform & {
			name: tl
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
		frontend~(fl,_): schema.#Docker & {
			name: fl
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
