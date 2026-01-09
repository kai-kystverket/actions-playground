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
		"frontend-a"~(fl,a): schema.#Docker & {
			name: fl
			paths: [
				"shared/" + fl + "/**",
			]
		}
		"frontend-b"~(fb,_): schema.#Docker & {
			name: fb
			dependsOn: [terraform, a]
			paths: [
				"shared/" + fb + "/**",
			]
		}
	}
}
