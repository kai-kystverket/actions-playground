package schema

import (
	git "cue.dev/x/githubactions"
)

#Docker: #Job & {
	name: string
	type: "docker"

	build: git.#Job & {
		name: string | *"build"
		uses: "./.github/workflows/reusable_build.yaml"
		// 	with: {
		// 		"test": "test"
		// 	}
	}
	main: git.#Job & {
		name: string | *"deploy"
		uses: "./.github/workflows/reusable_deploy.yaml"
		permissions: {
			packages: "write"
		}
		// 	with: {
		// 		"test": "test"
		// 	}
	}
}

#BaseDocker: git.#Workflow & {
	on: workflow_call: inputs: {
		"github-environment": {
			required: false
			type:     "string"
		}
	}
	permissions: {
		contents: "read"
	}
}

#ReusableBuild: #BaseDocker & {
	name: "reusable build"
	permissions: {
		packages: "write"
	}
	jobs: build: {
		"runs-on":         "ubuntu-latest"
		"timeout-minutes": 15
		environment:       "${{ inputs.github-environment }}"
		steps: [
			{
				name:  "fake build"
				shell: "bash"
				run: """
					echo build
					"""
			},
		]
	}
}
#ReusableDeploy: #BaseDocker & {
	name: "reusable deploy"
	jobs: deploy: {
		"runs-on":         "ubuntu-latest"
		"timeout-minutes": 15
		environment:       "${{ inputs.github-environment }}"
		steps: [
			{
				name:  "fake deploy"
				shell: "bash"
				run: """
					echo deploy
					"""
			},
		]
	}
}
