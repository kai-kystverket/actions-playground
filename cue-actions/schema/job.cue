package schema

import (
	git "cue.dev/x/githubactions"
)

#Environments: {
	name!:     string
	requires?: string
}

#Job: {
	name!: string
	paths!: [...string]
	envs: [...#Environments] | *[
		{
			name: "dev"
		}, {
			name:     "test"
			requires: "dev"
		}, {
			name:     "prod"
			requires: "test"
		},
	]

	type:          "docker" | "terraform"
	pull_request?: git.#Job
	main?:         git.#Job
	...
}
