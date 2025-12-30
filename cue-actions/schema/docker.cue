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
	// 	deploy_container_app: git.#Workflow.#reusableWorkflowCallJob & {
	// 		// The name of the container app in Azure Container Apps
	// 		"container-app-name": string | *name
	// 		// description: The resource group containing the container app
	// 		"resource-group-name": string
	// 	}
	// 	deploy_container_app_job: git.#Workflow.#reusableWorkflowCallJob & {
	// 		// The name of the container app in Azure Container Apps
	// 		"container-app-name": string | *name
	// 		// description: The resource group containing the container app
	// 		"resource-group-name": string
	// 	}
	// 	deploy_container_app_job_instance: git.#Workflow.#reusableWorkflowCallJob & {
	// 		// The name of the container app in Azure Container Apps
	// 		"container-app-name": string | *name
	// 		// description: The resource group containing the container app
	// 		"resource-group-name": string
	// 	}
}
