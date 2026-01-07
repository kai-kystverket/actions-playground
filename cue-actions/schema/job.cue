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

	type: "docker" | "terraform"
	// Runs on pull reuqests
	pull_request?: git.#Job
	// Runs on main branch for each environment
	deploy?: git.#Job
	// Runs before deploy
	build?: git.#Job
	...
}
