@experiment(aliasv2)
package actions

import (
	schema "actions.cue/schema"
)

actions: "my-repo": schema.#SuperDeploy & {
	config: jobs: {
		terraform~(tl,_): schema.#Terraform & {
			name: tl
		}
		frontend~(fl,_): schema.#Docker & {
			name: fl
			paths: [
				fl + "/**",
			]
		}
	}
}
