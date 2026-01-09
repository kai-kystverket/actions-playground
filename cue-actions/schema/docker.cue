package schema

import (
	git "cue.dev/x/githubactions"
)

#Docker: #Job & {
	name: string
	type: "docker"
	build: git.#Job & {
		name:        string | *"build"
		uses:        "./.github/workflows/reusable-build.yaml"
		permissions: #ReusableDockerBuild.permissions
		// 	with: {
		// 		"test": "test"
		// 	}
	}
	pullRequestForEachEnv: false
	pullRequest: git.#Job & {
		name:        string | *"build"
		uses:        "./.github/workflows/reusable-build.yaml"
		permissions: #ReusableDockerBuild.permissions
		// 	with: {
		// 		"test": "test"
		// 	}
	}
	main: git.#Job & {
		name:        string | *"deploy"
		uses:        "./.github/workflows/reusable-deploy.yaml"
		permissions: #ReusableDockerDeploy.permissions
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

#ReusableDockerBuild: #BaseDocker & {
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
#ReusableDockerDeploy: #BaseDocker & {
	name: "reusable deploy"
	permissions: {
		"id-token": "write"
	}
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
