package schema

import (
	git "cue.dev/x/githubactions"
)

#Docker: #Job & {
	name: string
	type: "docker"
	build_and_push: git.#Workflow.#reusableWorkflowCallJob & {
		name: "build"
		uses: "./test.yaml"
		with: {
			// Image name to be tagged
			containerfile: string | *"Dockerfile"
			// The directory (context) containing the Dockerfile
			"dockerfile-directory":     string | *name
			"container-app-name"?:      string
			"container-app-job-name"?:  string
			"container-instance-name"?: string
		}
	}
}
