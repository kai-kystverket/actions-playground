package schema

import (
	git "cue.dev/x/githubactions"
)

#Docker: #Job & {
	name: string
	type: "docker"

	build: git.#Job & {
		name: string | *"build"
		uses: "./build.yaml"
		with: {
			"test": "test"
		}
	}
	main: git.#Job & {
		name: string | *"deploy"
		uses: "./deploy.yaml"
		with: {
			"test": "test"
		}
	}
}
