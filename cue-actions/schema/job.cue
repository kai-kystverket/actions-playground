package schema

import (
	git "cue.dev/x/githubactions"
)

#Environments: {
	name!: "dev" | "test" | "prod"
	// Specify which environment should be run first
	requires?: "dev" | "test" | "prod"
}

#Job: {
	name!: string
	// Paths to trigger CI
	paths!: [...string]
	// List over environments to run
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

	// Other jobs that must complete successfully before this job will run
	dependsOn?: [...string]

	// predefined job templates
	type?: "docker" | "terraform"
	// Runs on pull reuqests
	pull_request?: git.#Job
	// Runs on main branch for each environment
	deploy?: git.#Job
	// Runs before deploy
	build?: git.#Job
	...
}
