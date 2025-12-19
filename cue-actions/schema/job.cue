package schema

import (
	git "cue.dev/x/githubactions"
)

#Job: {
	name!: string
	paths!: [...string]
	envs: {
		dev:  string | *""
		test: string | *"dev"
		prod: string | *"test"
	}
	type:          "docker" | "terraform"
	pull_request?: git.#Job
	main?:         git.#Job
	...
}
